package org.whitehotstone.security.wsdl.crawler.handling

import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Map.Entry
import java.nio.file.Files
import java.nio.file.Path

import com.google.inject.Inject
import com.google.common.base.Splitter
import com.google.common.collect.ImmutableSet
import com.google.common.collect.Multimap

import org.whitehotstone.security.wsdl.crawler.model.WsdlAdapter
import org.whitehotstone.security.wsdl.crawler.model.configuration.Configuration
import org.whitehotstone.security.wsdl.crawler.model.graph.wsdl.ServiceGraphBuilder
import org.whitehotstone.security.wsdl.crawler.model.graph.DFSDigraphTraversal
import org.whitehotstone.security.wsdl.crawler.model.graph.wsdl.ServiceInterfaceVisitor
import org.whitehotstone.security.wsdl.crawler.model.ServiceMiningResult
import org.whitehotstone.security.wsdl.crawler.model.ServiceDefinitionMiningResult

import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.*

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState

import static extension org.whitehotstone.security.wsdl.crawler.xml.XPaths.xpathChildren
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.loadXml

class Functions {

//    @Inject
//    Parameters parameters
    @Inject
    Configuration configuration

    static val LINE_SEPARATOR = System.lineSeparator

    val HANDLE_WSDL_SOURCE_2 = [ Path sourcePath |
        val path = sourcePath.toRealPath

        val wsdlDocument = path.loadXml
        val wsdl = new WsdlAdapter(wsdlDocument, path)

        val providerKeywords = configuration.sources.wsdl.serviceTypes.findFirst[serviceType == 'synchronous/provider'].tags
        providerKeywords.checkNotNull()
        (!providerKeywords.nullOrEmpty).checkState

        val result = new ServiceDefinitionMiningResult(wsdl)

        for (service : wsdl.service.entrySet) {
            val serviceName = service.key

            val graphBuilder = new ServiceGraphBuilder
            val graph = graphBuilder.build(wsdl, serviceName)

            val visitor = new ServiceInterfaceVisitor(configuration.getDictionary)
            val operations = graph.rootVertices
            for (operation : operations) {
                val parts = graph.connectedVertices(operation)
                for (part : parts) {
                    DFSDigraphTraversal.traverse(graph, part, visitor, newArrayList(#[operation]))
                }
            }
            val toMask = visitor.toMask
            val toHide = visitor.toHide

            result.addServiceMiningResult(new ServiceMiningResult(serviceName, toMask, toHide))

        }

        return result
    ]
    val HANDLE_WSDL_SOURCE_RESULT_2 = [ ServiceDefinitionMiningResult sourceResults |
        return sourceResults
    ]

    val HANDLE_WSDL_SOURCE_RESULTS = [ List<ServiceDefinitionMiningResult> allResults |
        val sb = new StringBuilder
        val sbExtra = new StringBuilder

        val serviceTypes = configuration.sources.wsdl.serviceTypes
        val mergeStrategiesMap = configuration.sourceHandling.wsdl.mergeStrategies.toMap[it.serviceType]

        val serviceDefinitions = configuration.sources.wsdl.serviceDefinitions
        val serviceMappings = configuration.generator.sqlConfig.wsdl.serviceMappings

        val resultsPerArtifact = allResults.groupBy[wsdlLocation.detectArtifactId]
        for(resultsOfArtifactEntry : resultsPerArtifact.entrySet) {
            val artifactId = resultsOfArtifactEntry.key
            val cArtifactId = artifactId.mapArtifactId

            val resultsOfArtifact = resultsOfArtifactEntry.value

            val resultsPerServiceType =
                resultsOfArtifact.groupBy[
                    val namespace = it.targetNamespace
                    val serviceTypeObject = serviceTypes.findFirst[tags.exists[namespace.contains(it)]]
                    if(serviceTypeObject == null) {
                        return 'default'
                    }
                    else {
                        return serviceTypeObject.serviceType
                    }
                ]

            for(resultsOfServiceTypeEntry : resultsPerServiceType.entrySet) {
                val serviceType = resultsOfServiceTypeEntry.key
                val resultsOfServiceType = resultsOfServiceTypeEntry.value

                // Let's do not create strategy implementation classes for now.
                val howToMerge = mergeStrategiesMap.get(serviceType)
                val mergeServices = howToMerge.mergeStrategies.contains('services')
                val mergeServiceOperations = howToMerge.mergeStrategies.contains('service-operations')
                val mergeAsyncServiceOperationMessages = howToMerge.mergeStrategies.contains('async-service-operation-messages')

                val extraProperties = <Pair<String, String>>newArrayList
                // ########### MERGE SERVICES #####################################################################################################
                if(mergeServices && !mergeAsyncServiceOperationMessages) {

                    val appropriateServiceDefinition = serviceDefinitions.findFirst[
                        val sdefinition = it;
                        resultsOfServiceType.exists[
                            targetNamespace.contains(sdefinition.namespace) && serviceMiningResults.exists[ serviceName == sdefinition.serviceName ]
                        ]
                    ]
                    val appropriateServiceMapping = if (appropriateServiceDefinition == null) null else serviceMappings.findFirst[ serviceDefinitionId == appropriateServiceDefinition.id ]

                    val serviceMiningResults = resultsOfServiceType.map[serviceMiningResults].flatten.toList
                    val mappedServiceName = appropriateServiceMapping?.configNamePrefix ?: serviceMiningResults.head.serviceName.toFirstLower

                    val mnames = defineServiceConfigMessageTypes(resultsOfServiceType.get(0))
                    val i_mp = mnames.get(0); val o_mp = mnames.get(1); val i_hp = mnames.get(2); val o_hp = mnames.get(3)

                    val mappedArtifactId = appropriateServiceMapping?.artifactId ?: cArtifactId

                    sb.append(
                        '''
                            ----------- Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                            -- The following services are covered: «serviceMiningResults.map[serviceName].join(', ')» 
                            -----------
                            «commonServiceTypeConfig(mappedArtifactId, mappedServiceName, i_mp, o_mp, i_hp, o_hp, serviceMiningResults, extraProperties)»

                            «postSqlConfig(mappedServiceName, mappedArtifactId)»
                            ----------- End of Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                            -------------------------------------------------------------------------------------------------------------------------
                            «LINE_SEPARATOR»
                        '''
                    )
                }
                // ########### MERGE OPERATIONS ###################################################################################################
                else if(mergeServiceOperations && !mergeServices && !mergeAsyncServiceOperationMessages) {
                    for (serviceDefinitionResult : resultsOfServiceType) {
                        val mnames = defineServiceConfigMessageTypes(serviceDefinitionResult)
                        val i_mp = mnames.get(0); val o_mp = mnames.get(1); val i_hp = mnames.get(2); val o_hp = mnames.get(3)

                        for (serviceMiningResult : serviceDefinitionResult.serviceMiningResults) {
                            val appropriateServiceDefinition = serviceDefinitions.findFirst[
                                serviceDefinitionResult.targetNamespace.contains(namespace) && serviceMiningResult.serviceName == serviceName 
                            ]
                            val appropriateServiceMapping = if (appropriateServiceDefinition == null) null else serviceMappings.findFirst[serviceDefinitionId == appropriateServiceDefinition.id]

                            val mappedServiceName = appropriateServiceMapping?.configNamePrefix ?: serviceMiningResult.serviceName.toFirstLower

                            val toMask = serviceMiningResult.dataToMask
                            val toHide = serviceMiningResult.dataToHide

                            val mappedArtifactId = appropriateServiceMapping?.artifactId ?: cArtifactId

                            sb.append(
                                '''
                                    ----------- Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -- The following operations are covered:
                                    -- Masking: «toMask.keys.toSet.join(', ')»;
                                    -- Hiding: «toHide.keys.toSet.join(', ')»
                                    «singleServiceConfig(mappedArtifactId, mappedServiceName, i_mp, o_mp, i_hp, o_hp, toMask, toHide, extraProperties)»

                                    «postSqlConfig(mappedServiceName, mappedArtifactId)»
                                    ----------- End of Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -------------------------------------------------------------------------------------------------------------------------
                                    «LINE_SEPARATOR»
                                '''
                            )
                        }
                    }
                }
                // ########### MERGE ASYNC SERVICE MESSAGES (e.g. THOP) ###########################################################################
                else if(mergeAsyncServiceOperationMessages && !mergeServices && !mergeServiceOperations) {
                    // We do not look for services in other wsdl files
                    for (serviceDefinitionResult : resultsOfServiceType) {
                        val serviceResults = serviceDefinitionResult.serviceMiningResults
                        val callbackServiceResult = serviceResults.findFirst[serviceName.toLowerCase.contains('callback')]
                        val outgoingServiceNamePart = callbackServiceResult.serviceName.toLowerCase.replaceAll('callback', '')
                        val serviceResult = serviceResults.findFirst[serviceName.toLowerCase.contains(outgoingServiceNamePart)]

                        val mnames = defineServiceConfigMessageTypes(serviceDefinitionResult)
                        val i_mp = mnames.get(0); val o_mp = mnames.get(1); val i_hp = mnames.get(2); val o_hp = mnames.get(3)
                        {
                            val appropriateServiceDefinition = serviceDefinitions.findFirst[
                                serviceDefinitionResult.targetNamespace.contains(namespace) && serviceResult.serviceName == serviceName 
                            ]
                            val appropriateServiceMapping = if (appropriateServiceDefinition == null) null else serviceMappings.findFirst[serviceDefinitionId == appropriateServiceDefinition.id]
                            
                            val mappedServiceName = appropriateServiceMapping?.configNamePrefix ?: serviceResult.serviceName.toFirstLower
                            val maskMap = serviceResult.dataToMask.asMap
                            val hideMap = serviceResult.dataToHide.asMap
                            val hideMapRules = hideMap.mapValues[if (it.nullOrEmpty) emptyList else it.filter[!value.nullOrEmpty]]

                            val mappedArtifactId = appropriateServiceMapping?.artifactId ?: cArtifactId

                            sb.append(
                                '''
                                    ----------- Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -- Masking config:
                                    «FOR operationRules : maskMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationMaskingConfig(operationRules, hideMapRules, mappedArtifactId, mappedServiceName, i_mp, o_mp, extraProperties, true)»
                                    «ENDFOR»
                                    -- Hiding config:
                                    «FOR operationRules : hideMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationHidingConfig(operationRules, mappedArtifactId, mappedServiceName, i_hp, o_hp, extraProperties, true)»
                                    «ENDFOR»
                                    «postSqlConfig(mappedServiceName, mappedArtifactId)»
                                    ----------- End of Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -------------------------------------------------------------------------------------------------------------------------
                                    «LINE_SEPARATOR»
                                '''
                            )
                        }
                        {
                            val appropriateServiceDefinition = serviceDefinitions.findFirst[
                                serviceDefinitionResult.targetNamespace.contains(namespace) && callbackServiceResult.serviceName == serviceName 
                            ]
                            val appropriateServiceMapping = if (appropriateServiceDefinition == null) null else serviceMappings.findFirst[serviceDefinitionId == appropriateServiceDefinition.id]

                            val mappedServiceName = appropriateServiceMapping?.configNamePrefix ?: callbackServiceResult.serviceName.toFirstLower
                            val maskMap = callbackServiceResult.dataToMask.asMap.mapValues[map['output' -> value].toList as Collection<Pair<String, String>>]
                            val hideMap = callbackServiceResult.dataToHide.asMap.mapValues[map['output' -> value].toList as Collection<Pair<String, String>>]
                            val hideMapRules = hideMap.mapValues[if (it.nullOrEmpty) emptyList else it.filter[!value.nullOrEmpty]]

                            val mappedArtifactId = appropriateServiceMapping?.artifactId ?: cArtifactId

                            sb.append(
                                '''
                                    ----------- Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -- Masking config:
                                    «FOR operationRules : maskMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationMaskingConfig(operationRules, hideMapRules, mappedArtifactId, mappedServiceName, i_mp, o_mp, extraProperties, true)»
                                    «ENDFOR»
                                    -- Hiding config:
                                    «FOR operationRules : hideMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationHidingConfig(operationRules, mappedArtifactId, mappedServiceName, i_hp, o_hp, extraProperties, true)»
                                    «ENDFOR»
                                    «postSqlConfig(mappedServiceName, mappedArtifactId)»
                                    ----------- End of Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -------------------------------------------------------------------------------------------------------------------------
                                    «LINE_SEPARATOR»
                                '''
                            )
                        }
                    }
                }
                // ########### DO NOT MERGE #######################################################################################################
                else {
                    for (serviceDefinitionResult : resultsOfServiceType) {
                        val mnames = defineServiceConfigMessageTypes(serviceDefinitionResult)
                        val i_mp = mnames.get(0); val o_mp = mnames.get(1); val i_hp = mnames.get(2); val o_hp = mnames.get(3)

                        for (serviceMiningResult : serviceDefinitionResult.serviceMiningResults) {
                            val appropriateServiceDefinition = serviceDefinitions.findFirst[
                                serviceDefinitionResult.targetNamespace.contains(namespace) && serviceMiningResult.serviceName == serviceName 
                            ]
                            val appropriateServiceMapping = if (appropriateServiceDefinition == null) null else serviceMappings.findFirst[serviceDefinitionId == appropriateServiceDefinition.id]

                            val mappedServiceName = appropriateServiceMapping?.configNamePrefix ?: serviceMiningResult.serviceName.toFirstLower

                            val toMask = serviceMiningResult.dataToMask
                            val toHide = serviceMiningResult.dataToHide
                            val maskMap = toMask.asMap
                            val hideMap = toHide.asMap
                            val hideMapRules = hideMap.mapValues[if (it.nullOrEmpty) emptyList else it.filter[!value.nullOrEmpty]]

                            val mappedArtifactId = appropriateServiceMapping?.artifactId ?: cArtifactId

                            sb.append(
                                '''
                                    ----------- Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -- Masking config:
                                    «FOR operationRules : maskMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationMaskingConfig(operationRules, hideMapRules, mappedArtifactId, mappedServiceName, i_mp, o_mp, extraProperties, false)»
                                    «ENDFOR»
                                    -- Hiding config:
                                    «FOR operationRules : hideMap.entrySet SEPARATOR LINE_SEPARATOR + '--'»
                                        «singleOperationHidingConfig(operationRules, mappedArtifactId, mappedServiceName, i_hp, o_hp, extraProperties, false)»
                                    «ENDFOR»
                                    «postSqlConfig(mappedServiceName, mappedArtifactId)»
                                    ----------- End of Secure Logging Configuration for '«mappedServiceName»'; Service type: «serviceType» -----------
                                    -------------------------------------------------------------------------------------------------------------------------
                                    «LINE_SEPARATOR»
                                '''
                            )
                        }
                    }
                }

                if(!extraProperties.empty) {
                    sbExtra.append(
                        '''
                            «FOR extraProperty : extraProperties»
                                «extraProperty.key»=«extraProperty.value»
                            «ENDFOR»
                        '''
                    )
                    extraProperties.clear
                }
            }
        }
        return #{'main' -> sb.toString, 'extra' -> sbExtra.toString}
    ]

    def defineServiceConfigMessageTypes(ServiceDefinitionMiningResult serviceDefinitionResult) {
        val providerKeywords = configuration.sources.wsdl.serviceTypes.findFirst[serviceType == 'synchronous/provider'].tags
        providerKeywords.checkNotNull()
        (!providerKeywords.nullOrEmpty).checkState
        val isOwn = providerKeywords.forall[serviceDefinitionResult.targetNamespace.toLowerCase.contains(it.toLowerCase)]

        val cnames = configuration.generator.sqlConfig.wsdl.configNames
        val i_mp = if (isOwn) cnames.patternMaskedIncoming else cnames.patternMaskedOutcoming
        val o_mp = if (isOwn) cnames.patternMaskedOutcoming else cnames.patternMaskedIncoming
        val i_hp = if (isOwn) cnames.patternHiddenIncoming else cnames.patternHiddenOutcoming
        val o_hp = if (isOwn) cnames.patternHiddenOutcoming else cnames.patternHiddenIncoming

        return #[i_mp, o_mp, i_hp, o_hp]
    }

    def commonServiceTypeConfig(String artifactId, String serviceName, String i_mp, String o_mp, String i_hp, String o_hp,
        List<ServiceMiningResult> serviceResults,
        List<Pair<String, String>> extraProperties
    ) {
        val List<String> allInputHPatterns = newArrayList
        val List<String> allOutputHPatterns = newArrayList

        val List<String> allInputMPatterns = newArrayList
        val List<String> allOutputMPatterns = newArrayList

        for (serviceResult : serviceResults) {
            val toHide = serviceResult.dataToHide
            val hiddenPatterns = toHide.values.filterNull.groupBy[it.key].mapValues[ImmutableSet.copyOf(it).filterNull]
            val inputHPatterns = if (hiddenPatterns.get('input') != null) hiddenPatterns.get('input').map[value].toList.filterPartialPatterns else emptyList
            val outputHPatterns = if (hiddenPatterns.get('output') != null) hiddenPatterns.get('output').map[value].toList.filterPartialPatterns else emptyList
    
            val toMask = serviceResult.dataToMask
            val maskedPatterns = toMask.values.filterNull.groupBy[it.key].mapValues[ImmutableSet.copyOf(it).filterNull]
            val inputMPatterns = if (maskedPatterns.get('input') != null) maskedPatterns.get('input').map[value].toList.filterPartialPatterns.filter[val mp = it; !inputHPatterns.exists[mp.contains(it)]] else emptyList
            val outputMPatterns = if (maskedPatterns.get('output') != null) maskedPatterns.get('output').map[value].toList.filterPartialPatterns.filter[val mp = it; !outputHPatterns.exists[mp.contains(it)]] else emptyList

            allInputHPatterns.addAll(inputHPatterns)
            allOutputHPatterns.addAll(outputHPatterns)

            allInputMPatterns.addAll(inputMPatterns)
            allOutputMPatterns.addAll(outputMPatterns)
        }

        val iHPatterns = ImmutableSet.copyOf(allInputHPatterns.filterPartialPatterns).toList
        val oHPatterns = ImmutableSet.copyOf(allOutputHPatterns.filterPartialPatterns).toList
        val iMPatterns = ImmutableSet.copyOf(allInputMPatterns.filterPartialPatterns).filter[val mp = it; !iHPatterns.exists[mp.contains(it)]].toList
        val oMPatterns = ImmutableSet.copyOf(allOutputMPatterns.filterPartialPatterns).filter[val mp = it; !oHPatterns.exists[mp.contains(it)]].toList

        val sqlConfig = new StringBuilder
        appendToSqlConfig(artifactId, '''«serviceName».«i_mp»''', iMPatterns.join(';'), 'requests, which should be masked', iMPatterns, sqlConfig, extraProperties)
        sqlConfig.append(LINE_SEPARATOR)
        appendToSqlConfig(artifactId, '''«serviceName».«o_mp»''', oMPatterns.join(';'), 'responses, which should be masked', oMPatterns, sqlConfig, extraProperties)
        sqlConfig.append(LINE_SEPARATOR)
        appendToSqlConfig(artifactId, '''«serviceName».«i_hp»''', iHPatterns.join(';'), 'requests, which should be hidden', iHPatterns, sqlConfig, extraProperties)
        sqlConfig.append(LINE_SEPARATOR)
        appendToSqlConfig(artifactId, '''«serviceName».«o_hp»''', oHPatterns.join(';'), 'responses, which should be hidden', oHPatterns, sqlConfig, extraProperties)
        sqlConfig.append(LINE_SEPARATOR)
        return sqlConfig.toString
    }

    def singleServiceConfig(String artifactId, String serviceName, String i_mp, String o_mp, String i_hp, String o_hp,
        Multimap<String, Pair<String, String>> toMask,
        Multimap<String, Pair<String, String>> toHide,
        List<Pair<String, String>> extraProperties
    ) {
        val hiddenPatterns = toHide.values.filterNull.groupBy[it.key].mapValues[ImmutableSet.copyOf(it).filterNull]
        val inputHPatterns = if (hiddenPatterns.get('input') != null) hiddenPatterns.get('input').map[value].toList.filterPartialPatterns else emptyList
        val outputHPatterns = if (hiddenPatterns.get('output') != null) hiddenPatterns.get('output').map[value].toList.filterPartialPatterns else emptyList
        val maskedPatterns = toMask.values.filterNull.groupBy[it.key].mapValues[ImmutableSet.copyOf(it).filterNull]
        val inputMPatterns = if (maskedPatterns.get('input') != null) maskedPatterns.get('input').map[value].toList.filterPartialPatterns.filter[val mp = it; !inputHPatterns.exists[mp.contains(it)]] else emptyList
        val outputMPatterns = if (maskedPatterns.get('output') != null) maskedPatterns.get('output').map[value].toList.filterPartialPatterns.filter[val mp = it; !outputHPatterns.exists[mp.contains(it)]] else emptyList

        val sqlConfig = new StringBuilder
        appendToSqlConfig(artifactId, '''«serviceName».«i_mp»''', inputMPatterns.join(';'), 'requests, which should be masked', inputMPatterns, sqlConfig, extraProperties)
        appendToSqlConfig(artifactId, '''«serviceName».«o_mp»''', outputMPatterns.join(';'), 'responses, which should be masked', outputMPatterns, sqlConfig, extraProperties)
        appendToSqlConfig(artifactId, '''«serviceName».«i_hp»''', inputHPatterns.join(';'), 'requests, which should be hidden', inputHPatterns, sqlConfig, extraProperties)
        appendToSqlConfig(artifactId, '''«serviceName».«o_hp»''', outputHPatterns.join(';'), 'responses, which should be hidden', outputHPatterns, sqlConfig, extraProperties)
        return sqlConfig.toString
    }
    
    def singleOperationMaskingConfig(
        Entry<String, Collection<Pair<String, String>>> operationRules,
        Map<String, Iterable<Pair<String, String>>> hideMapRules,
        String artifactId, String serviceName, String i_mp, String o_mp,
        List<Pair<String, String>> extraProperties, boolean skipEmpty
    ) {
        val operationName = operationRules.key
        val hideRules = hideMapRules.get(operationName) ?: emptyList
        val inputRules = operationRules.value.filter[key == 'input' && value != null].map[value].toList.filterPartialPatterns.toSet.filter[val mp = it; !hideRules.exists[key == 'input' && mp.contains(value)]]
        val outputRules = operationRules.value.filter[key == 'output' && value != null].map[value].toList.filterPartialPatterns.toSet.filter[val mp = it; !hideRules.exists[key == 'output' && mp.contains(value)]]

        val sqlConfig = new StringBuilder
        if(!inputRules.nullOrEmpty || !skipEmpty) {
            appendToSqlConfig(artifactId, '''«serviceName».«i_mp».«operationName»''', inputRules.join(';'), 'requests, which should be masked', inputRules, sqlConfig, extraProperties)
        }
        if(!outputRules.nullOrEmpty || !skipEmpty) {
            appendToSqlConfig(artifactId, '''«serviceName».«o_mp».«operationName»''', outputRules.join(';'), 'responses, which should be masked', outputRules, sqlConfig, extraProperties)
        }
        return sqlConfig.toString
    }

    def singleOperationHidingConfig(
        Entry<String, Collection<Pair<String, String>>> operationRules,
        String artifactId, String serviceName, String i_hp, String o_hp,
        List<Pair<String, String>> extraProperties, boolean skipEmpty
    ) {
        val operationName = operationRules.key
        val inputRules = ImmutableSet.copyOf(operationRules.value.filter[key == 'input' && value != null].map[value].toList).toList.filterPartialPatterns
        val outputRules = ImmutableSet.copyOf(operationRules.value.filter[key == 'output' && value != null].map[value].toList).toList.filterPartialPatterns

        val sqlConfig = new StringBuilder
        if(!inputRules.nullOrEmpty || !skipEmpty) {
            appendToSqlConfig(artifactId, '''«serviceName».«i_hp».«operationName»''', inputRules.join(';'), 'requests, which should be masked', inputRules, sqlConfig, extraProperties)
        }
        if(!outputRules.nullOrEmpty || !skipEmpty) {
            appendToSqlConfig(artifactId, '''«serviceName».«o_hp».«operationName»''', outputRules.join(';'), 'responses, which should be masked', outputRules, sqlConfig, extraProperties)
        }
        return sqlConfig.toString
    }

    def void appendToSqlConfig(String artifactId, String name, String text, String descriptionPart, Iterable<String> rules, StringBuilder sqlConfig, List<Pair<String, String>> extraProperties) {
        if(!text.empty && text.length <= 4000) {
            sqlConfig.append(singleSqlConfig(artifactId, name, text.splitConfigValue, descriptionPart, !rules.empty))
        }
        else {
            sqlConfig.append(singleSqlConfig(artifactId, name, if(rules.empty) '' else 'dummy', descriptionPart, !rules.empty))
            if(!rules.empty) {
                extraProperties.add('''«artifactId»#«name»''' -> text)
            }
        }
    }

    def singleSqlConfig(String artifactId, String name, String text, String descriptionPart, boolean enabled) {
        '''
            SQLFOR('«name»', 'The list of tag names, which contains sensitive data in «descriptionPart».', '«artifactId»');
        '''
    }

    def postSqlConfig(String serviceName, String artifactId) {
        '''
            POSTSQLFOR('«serviceName».propagate.escaped.xml', '«artifactId»');
        '''
    }

    def splitConfigValue(String configValue) {
        val int maxConfigValueLength = 2000
        if (configValue == null) {
            return null;
        }
        if (configValue.length < maxConfigValueLength) {
            return configValue;
        }
        if (configValue.length > 4000) {
            // TODO 2015-11-22 rischr we only support values up to 4000 byte in the database
        }
        
        return Splitter.fixedLength(maxConfigValueLength).split(configValue).join('\'' +  LINE_SEPARATOR + '||\'')
    }


    // =========================================================================================================================
    def filterPartialPatterns(List<String> strings) {
        if (!configuration.getDictionary.getSwallowPartialPatterns) {
            return strings
        }
        val iter = strings.iterator
        while(iter.hasNext) {
            val current = iter.next
            val commonOne = strings.findFirst[current.endsWith(it) && current.length > it.length]
            if(!commonOne.nullOrEmpty) {
                iter.remove
            }
        }
        return strings
    }
    // =========================================================================================================================

    def detectArtifactId(Path path) {
        path.checkNotNull
        val apath = path.toAbsolutePath
        val paths = <Path>newArrayList
        var parent = apath.parent
        while (parent != null) {
            paths.add(parent)
            parent = parent.parent
        }
        val pom = paths.findFirst [
            Files.exists(it.resolve('pom.xml'))
        ]?.resolve('pom.xml')

        pom.checkNotNull('''Unable to locate a POM file somewhere in '«pom»'.''')
        val documentRoot = pom.loadXml.rootElement
        val artifactId = #[MAVEN.ns -> 'project', MAVEN.ns -> 'artifactId'].xpathChildren.evaluateFirst(documentRoot)
        artifactId.checkNotNull('''Cannot fetch artifactId from the POM file '«pom»'.''')
        val text = artifactId.textTrim;
        (!text.nullOrEmpty).checkState('''Wrong artifactId inside the POM file '«pom»'.''')
        return text
    }

    def mapArtifactId(String artifactId) {
        val artifactIdMappings = if (configuration.sourceHandling.artifactIds != null && !configuration.sourceHandling.artifactIds.nullOrEmpty)
                newHashMap(configuration.sourceHandling.artifactIds.map [
                    get(0) -> get(1)
                ])
            else
                emptyMap
        val mappedArtifactId = artifactIdMappings.get(artifactId) ?: artifactId
        return mappedArtifactId
    }

    val FUNCTIONS = #{
        Name.WSDL_SOURCE -> HANDLE_WSDL_SOURCE_2,
        Name.WSDL_SOURCE_RESULT -> HANDLE_WSDL_SOURCE_RESULT_2,
        Name.WSDL_SOURCE_RESULTS -> HANDLE_WSDL_SOURCE_RESULTS
    }

    enum Name {
        WSDL_SOURCE,
        WSDL_SOURCE_RESULT,
        WSDL_SOURCE_RESULTS
    }

    def get(Name name) {
        FUNCTIONS.containsKey(name).checkArgument('''Unable to locate the function with the name '«name»'.''')
        FUNCTIONS.get(name)
    }
}
