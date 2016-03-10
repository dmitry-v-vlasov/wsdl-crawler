package org.whitehotstone.security.wsdl.crawler.model.graph.wsdl

import org.whitehotstone.security.wsdl.crawler.error.SensitiveDataToolException
import org.whitehotstone.security.wsdl.crawler.model.WsdlAdapter
import org.whitehotstone.security.wsdl.crawler.model.XsdAdapter
import org.whitehotstone.security.wsdl.crawler.model.graph.DirectedGraph
import org.whitehotstone.security.wsdl.crawler.model.graph.Vertex
import org.whitehotstone.security.wsdl.crawler.xml.StdNamespace
import java.util.ArrayDeque
import java.util.Map
import org.jdom2.Element
import org.jdom2.Namespace

import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.*

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.stdNamespaces
import static extension org.whitehotstone.security.wsdl.crawler.xml.XPaths.xpath
import static extension org.whitehotstone.security.wsdl.crawler.xml.XPaths.xpathr
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.aname
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.ereference

class ServiceGraphBuilder {
    def DirectedGraph<Element, Vertex<Element>> build(WsdlAdapter wsdl, String serviceName) {
        wsdl.checkNotNull
        
        val graph = new DirectedGraph<Element, Vertex<Element>>

        for ( service : wsdl.service.values ) {
            if (service.getAttributeValue('name') != serviceName) {
                // Do nothing
            }
            else {
                val snss = service.stdNamespaces
                val ports = service.getChildren('port', snss.get(WSDL))
                (!ports.nullOrEmpty).checkState
                for (port : ports) {
                    val bindingRef = port.ereference('binding')
                    bindingRef.checkNotNull
                    val binding = wsdl.binding.get(bindingRef.value)
                    binding.checkNotNull
                    val portTypeRef = binding.ereference('type')
                    portTypeRef.checkNotNull
                    val portType = wsdl.portType.get(portTypeRef.value)
                    portType.checkNotNull;
                    (portType.name == 'portType').checkState
                    val nspt = portType.stdNamespaces
    
                    val operations = portType.getChildren('operation', nspt.get(WSDL))
                    (!operations.nullOrEmpty).checkState
                    for (operation : operations) {
                        (operation.name == 'operation').checkState
    
                        val operationVertex = new XmlVertex(operation)
                        graph.addRootVertex(operationVertex)
    
                        val ons = operation.stdNamespaces
    
                        val input = operation.getChild('input', ons.get(WSDL))
                        val output = operation.getChild('output', ons.get(WSDL))
    
                        if (input != null) {
                            val inputVertex = new XmlVertex(input)
                            graph.addVertex(inputVertex)
                            graph.addEdge(operationVertex, inputVertex)
    
                            val requestRef = input.ereference('message')
                            val request = wsdl.message.get(requestRef.value)
                            request.checkNotNull
                            request.traverseOperationMessage(graph, wsdl, inputVertex)
                        }
                        if (output != null) {
                            val outputVertex = new XmlVertex(output)
                            graph.addVertex(outputVertex)
                            graph.addEdge(operationVertex, outputVertex)
    
                            val responseRef = output.ereference('message')
                            val response = wsdl.message.get(responseRef.value)
                            response.checkNotNull
                            response.traverseOperationMessage(graph, wsdl, outputVertex)
                        }
                    }
                }
            }
        }

        return graph
    }

    def traverseOperationMessage(Element operationMessage, DirectedGraph<Element, Vertex<Element>> graph, WsdlAdapter wsdl, XmlVertex operationElementVertex) {
        operationMessage.checkNotNull; graph.checkNotNull; wsdl.checkNotNull; operationElementVertex.checkNotNull

        val message = operationMessage
        message.checkNotNull;
        (message.name == 'message').checkState

        val messageVertex = new XmlVertex(message)
        graph.addVertex(messageVertex)
        graph.addEdge(operationElementVertex, messageVertex)

        val parts = wsdl.messagePart.get(message.aname)
        parts.checkNotNull
        
        for (part : parts) {
            val elementRef = part.ereference('element')
            val elementNamespace = elementRef.key
//            val elementName = elementRef.value

            var schemas = wsdl.schemas.get(elementNamespace)
            if (schemas.nullOrEmpty) schemas = wsdl.schemas.values.filter [
                it.imports.values.exists[it.getAttributeValue('namespace') == elementNamespace.URI]
            ].toList

            schemas.checkNotNull
            if (schemas.empty) return;
            (schemas.size == 1).checkState
            val schema = schemas.head

            val partVertex = new XmlVertex(part)
            graph.addVertex(partVertex)
            graph.addEdge(messageVertex, partVertex)

            part.traverseOperationPartSchema(graph, schema, elementRef, partVertex)
        }
    }

    def traverseOperationPartSchema(Element part, DirectedGraph<Element, Vertex<Element>> graph, XsdAdapter schema, Pair<Namespace, String> elementRef, XmlVertex partVertex) {
        var initialSchema = schema
        val messageElement = schema.fetchElementBy(elementRef.value) ?: {
            initialSchema = schema.fetchImportBy(elementRef.key)
            initialSchema.fetchElementBy(elementRef.value)
        }
        messageElement.checkNotNull

        val messageVertex = new XmlVertex(messageElement)
        graph.addVertex(messageVertex)
        graph.addEdge(partVertex, messageVertex)

        // === Traversal structures; The way of visiting is BFSish ===
        val schemaStack = new ArrayDeque<XsdAdapter>(8)
        schemaStack.push(initialSchema)

        val schemaQueueStack = new ArrayDeque<ArrayDeque<XmlVertex>>(8)
        val initialQueue = new ArrayDeque<XmlVertex>(32)
        initialQueue.add(messageVertex)
        schemaQueueStack.push(initialQueue)
        // ===========================================================

        while(!schemaQueueStack.empty) {
            val cschema = schemaStack.peek
            val stdns = cschema.schemaStdNamespaces

            val cqueue = schemaQueueStack.peek

            var boolean break = false

            while (!cqueue.empty && !break) {
                val cvertex = cqueue.poll

                if(cvertex.hasXmlElement) {
                    // Case 1: Initial message element.
                    // Case 2: Check for the case of parent->child schema loading with parent element in child queue.
                    if (!graph.vertexExists(cvertex)) {
                        graph.addVertex(cvertex)
                    }

                    if(cvertex.hasTypedElement) {
                        if (cvertex.hasAnonTypedElement) {
                            val customElementType = cvertex.object.elementType(null, stdns, cschema)
                            val aTypeVertex = new XmlVertex(customElementType, cvertex.elementDefinitionReference)
                            graph.addVertex(aTypeVertex)
                            graph.addEdge(cvertex, aTypeVertex)
        
                            cqueue.add(aTypeVertex)
                        }
                        else {
                            val typeReference = cvertex.object.ereference('type')
        
                            if(cvertex.vertexTypeIsBasic) {
                                // Do nothing; The current vertex is already dequeued; And the element should be in the graph at this stage already.
                            }
                            else {
                                val customElementType = cvertex.object.elementType(typeReference, stdns, cschema)
        
                                if(customElementType == null && cschema.imports.containsKey(typeReference.key)) {
                                    val childSchema = cschema.fetchImportBy(typeReference.key)
                                    if(childSchema != null) {
                                        schemaStack.push(childSchema)
        
                                        val childQueue = new ArrayDeque<XmlVertex>(32)
                                        childQueue.add(cvertex)
                                        schemaQueueStack.push(childQueue)
        
                                        break = true // And we go deeper to an imported schema from here.
                                    }
                                    else {
                                        throw new SensitiveDataToolException('''Cannot find type declaration among imported schemas for the type '«customElementType»'.''')
                                    }
                                }
                                else {
                                    if (customElementType == null) { // It looks like the whole schema may be broken...
                                        throw new SensitiveDataToolException('''Cannot find type declaration for the type '«customElementType»'.''')
                                    }
                                    // As soon as we have a good elementId for the XML-Schema type vertices we can compare them with "equals" method.
                                    val aTypeVertex = new XmlVertex(customElementType, typeReference)
                                    val registeredTypeVertex = graph.findSimilarVertex(aTypeVertex) as XmlVertex
                                    if (registeredTypeVertex == null) {
                                        graph.addVertex(aTypeVertex)
                                        graph.addEdge(cvertex, aTypeVertex)
        
                                        cqueue.add(aTypeVertex)
                                    }
                                    else {
                                        // element1  element2
                                        //        \ /
                                        //     same type
                                        graph.addEdge(cvertex, registeredTypeVertex)
                                    }
                                }
                            }
                        }
                    }
                    else if (cvertex.hasReferencedElement) {
                        val elementReference = cvertex.object.ereference('ref')

                        val referencingElement = elementReference.elementByReference(stdns, cschema)
                        if(referencingElement == null && cschema.imports.containsKey(elementReference.key)) {
                            val childSchema = cschema.fetchImportBy(elementReference.key)
                            if(childSchema != null) {
                                schemaStack.push(childSchema)

                                val childQueue = new ArrayDeque<XmlVertex>(32)
                                childQueue.add(cvertex)
                                schemaQueueStack.push(childQueue)

                                break = true
                            }
                            else {
                                throw new SensitiveDataToolException('''Cannot find element among imported schemas for the element reference '«elementReference»'.''')
                            }
                        }
                        else {
                            if (referencingElement == null) {
                                throw new SensitiveDataToolException('''Cannot find element for the element reference '«elementReference»'.''')
                            }
                            val aRefElementVertex = new XmlVertex(referencingElement, elementReference)
                            aRefElementVertex.referencingElement = true
                            val similarElementRefVertex = graph.findSimilarVertex(aRefElementVertex)
                            if(similarElementRefVertex == null) {
                                graph.addVertex(aRefElementVertex)
                                graph.addEdge(cvertex, aRefElementVertex)

                                cqueue.add(aRefElementVertex)
                            }
                            else {
                                graph.addEdge(cvertex, similarElementRefVertex)
                            }
                        }
                    }
                }
                else if (cvertex.hasTypeElement) {
                    val typeElement = cvertex.object
                    if(typeElement.name == 'simpleType' || (typeElement.name == 'complexType' && typeElement.getChild('simpleContent', stdns.get(XSD)) != null)) {
                        // Do nothing; The current vertex is already dequeued; And the element should be in the graph at this stage already. 
                    }
                    else {
                        val complexContent = typeElement.getChild('complexContent', stdns.get(XSD))
                        val baseTypeReference =
                            if (complexContent == null) {
                                null
                            }
                            else if (complexContent != null && complexContent.getChild('extension', stdns.get(XSD)) == null) {
                                null
                            }
                            else if (complexContent != null && complexContent.getChild('extension', stdns.get(XSD)) != null) {
                                complexContent.getChild('extension', stdns.get(XSD)).ereference('base')
                            }
                        if(baseTypeReference != null) {
                            val baseType = typeElement.elementType(baseTypeReference, stdns, cschema)
                            if (baseType != null) {
                                val aBaseTypeVertex = new XmlVertex(baseType, baseTypeReference)
                                val registeredBaseTypeVertex = graph.findSimilarVertex(aBaseTypeVertex)
                                if(registeredBaseTypeVertex == null ) {
                                    graph.addVertex(aBaseTypeVertex)
                                    graph.addEdge(cvertex, aBaseTypeVertex)

                                    cqueue.add(aBaseTypeVertex)
                                }
                                else {
                                    graph.addEdge(cvertex, registeredBaseTypeVertex)
                                }
                            }
                            else if (baseType == null && cschema.imports.containsKey(baseTypeReference.key)) {
                                val childSchema = cschema.fetchImportBy(baseTypeReference.key)
                                if(childSchema != null) {
                                    schemaStack.push(childSchema)

                                    val childQueue = new ArrayDeque<XmlVertex>(32)
                                    childQueue.add(cvertex)
                                    schemaQueueStack.push(childQueue)

                                    break = true
                                }
                            }
                        }

                        if (baseTypeReference == null || (baseTypeReference != null && break)) {
                            val typeElements = typeElement.complexTypeElements(stdns)
                            if (typeElements.empty) {
                                // Do nothing
                            }
                            else {
                                for (element : typeElements) {
                                    val elementVertex = new XmlVertex(element)
                                    graph.addVertex(elementVertex)
                                    graph.addEdge(cvertex, elementVertex)
    
                                    cqueue.add(elementVertex)
                                } 
                            }
                        }
                    }
                }
            }

            if(!break && cqueue.empty) {
                schemaStack.pop
                schemaQueueStack.pop
            }
        }
    }

    def vertexTypeIsBasic(XmlVertex vertex) {
        vertex.checkNotNull
        vertex.hasTypedElement && (vertex.hasPrimitiveTypeElement || vertex.hasDomainPrimitiveTypeElement)
    }

    def elementType(Element element, Pair<Namespace, String> type, Map<StdNamespace, Namespace> stdns, XsdAdapter cschema) {
        val etype = if (element.name == 'element' && type == null &&
                (element.getChild('complexType', stdns.get(XSD)) != null || element.getChild('simpleType', stdns.get(XSD)) != null)) {
                element.getChild('complexType', stdns.get(XSD)) ?: element.getChild('simpleType', stdns.get(XSD))
            } else {
                #[stdns.get(XSD) -> 'complexType'].xpath('name' -> type.value).evaluateFirst(cschema.schema) ?:
                    #[stdns.get(XSD) -> 'simpleType'].xpath('name' -> type.value).evaluateFirst(cschema.schema)
            }
        etype
    }

    def elementByReference(Pair<Namespace, String> elementRef, Map<StdNamespace, Namespace> stdns, XsdAdapter cschema) {
        //#[stdns.get(XSD) -> 'element'].xpathChildren('name' -> elementRef.value).evaluateFirst(cschema.schema)
        cschema.fetchElementBy(elementRef.value)
    }

    def complexTypeElements(Element etype, Map<StdNamespace, Namespace> stdns) {
        (etype.name == 'complexType').checkArgument
        val internalElements = #[stdns.get(XSD) -> 'element'].xpathr.evaluate(etype)
//        val typeElements = internalElements.sortWith([ e1, e2 |
//            if (e1 == null && e2 != null) {
//                return -1
//            } else if (e1 != null && e2 == null) {
//                return 1
//            } else if (e1 == null && e2 == null) {
//                return 0
//            } else {
//                return e1.name.compareTo(e2.name)
//            }
//        ]).filterNull.toList
        internalElements
    }
}
