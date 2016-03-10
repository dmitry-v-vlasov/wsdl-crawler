package org.whitehotstone.security.wsdl.crawler.model.graph.wsdl

import org.whitehotstone.security.wsdl.crawler.model.configuration.dictionary.Dictionary
import org.whitehotstone.security.wsdl.crawler.model.graph.Vertex
import org.whitehotstone.security.wsdl.crawler.model.graph.Visitor
import java.util.List
import org.jdom2.Element
import static extension com.google.common.collect.Multimaps.newListMultimap

import static extension com.google.common.base.Preconditions.checkState
import org.whitehotstone.security.wsdl.crawler.common.Suppliers
import java.util.HashMap
import java.util.Collection

class ServiceInterfaceVisitor implements Visitor<Element, Vertex<Element>> {

    Dictionary dictionary

    var toMask = newListMultimap(new HashMap<String, Collection<Pair<String, String>>>, P_SUPPLIER)
    var toHide = newListMultimap(new HashMap<String, Collection<Pair<String, String>>>, P_SUPPLIER)

    new(Dictionary dictionary) {
        this.dictionary = dictionary
    }

    override processVertexEarly(Vertex<Element> vertex) {
        // throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }

    override processEdge(Vertex<Element> source, Vertex<Element> target) {
        // throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }

    override processVertexLate(Vertex<Element> vertex) {
        // throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }

    override processAsLeaf(Vertex<Element> vertex, List<Vertex<Element>> discoveredPath) {
        val path = discoveredPath.filter[
            val xvertex = it as XmlVertex
            xvertex.hasOperationElement || xvertex.hasInputElement || xvertex.hasOutputElement || xvertex.hasMessageElement || xvertex.hasPartElement || xvertex.hasXmlElement
        ].map[it as XmlVertex].toList()
        (path.size >= 2).checkState

        val operation = path.get(0)
        val operationName = operation.object.getAttributeValue('name')

        var operationElementType = path.get(1).object.name

//        val message = path.get(2)
        // Dirty hack for T-HOP async messaging
//        if (message.object != null) {
//            val messageName = message.object.getAttributeValue('name')
//            val operationTypeByMessageName = if(messageName.endsWith('Request')) 'input' else if (messageName.endsWith('Response')) 'output' else null
//            if(operationTypeByMessageName != null && operationElementType != operationTypeByMessageName) {
//                operationElementType = operationTypeByMessageName
//            }
//        }
        // Dirty hack

//        val messagePart = path.get(3)

        val epath = path.subList(4, path.size)

        // ###########
        for (maskedPattern : dictionary.masked) {
            var StringBuilder newPattern = null
            var firstPatternPartHasBeenDetected = false
            var lastPatternIsAsterisk = false
            var currentPatternPartIndex = 0
            var firstElementIndexDetected = -1
            val lastElementIndex = epath.size - 1
            for (elementIndex : 0 ..< epath.size) {// Hello, C ...
                val element = epath.get(elementIndex)
                val elementName = element.object.getAttributeValue('name')

                if(currentPatternPartIndex < maskedPattern.parts.size) {
                    val currentPatternPart = maskedPattern.parts.get(currentPatternPartIndex)
                    lastPatternIsAsterisk = currentPatternPart == '*'
                    val elementNameContainsCurrentPatternPart = elementName.contains(currentPatternPart)
    
                    if(firstPatternPartHasBeenDetected || elementNameContainsCurrentPatternPart) {
                        if(elementNameContainsCurrentPatternPart) {
                            if (!firstPatternPartHasBeenDetected) {
                                firstElementIndexDetected = elementIndex
                                firstPatternPartHasBeenDetected = true
                            }
                            currentPatternPartIndex += if (lastPatternIsAsterisk) 0 else 1
                        }
    
                        if (newPattern == null) {
                            newPattern = new StringBuilder
                        }
    
                        newPattern.append(elementName).append('/')
    
                        if (elementIndex == lastElementIndex && (elementNameContainsCurrentPatternPart || lastPatternIsAsterisk)) {
                            if(element.hasDomainPrimitiveTypeElement) {
                                newPattern.append('value')
                            }
                            else {
                                newPattern.deleteCharAt(newPattern.length - 1)
                            }
                            newPattern.append('''{«maskedPattern.constraints.left»,«maskedPattern.constraints.right»}''')
    
                            if(dictionary.keepExtraTop > 0 && firstElementIndexDetected != -1 && firstElementIndexDetected > 0) {
                                var extraElementIndexToAppendOnTop = firstElementIndexDetected - dictionary.keepExtraTop
                                extraElementIndexToAppendOnTop = if (extraElementIndexToAppendOnTop < 0) 0 else extraElementIndexToAppendOnTop
    
                                val extraTopElements = epath.subList(extraElementIndexToAppendOnTop, firstElementIndexDetected)
                                val patternWithExtraElements = '''«FOR extraElement : extraTopElements SEPARATOR '/'»«extraElement.object.getAttributeValue('name')»«ENDFOR»/«newPattern.toString»'''
                                toMask.put(operationName, operationElementType -> patternWithExtraElements)
                            }
                            else {
                                toMask.put(operationName, operationElementType -> newPattern.toString)
                            }
                        }
                    }
                }
            }
        }
        // ###########

        // ###########
        for (hiddenPattern : dictionary.hiddenParts) {
            var StringBuilder newPattern = null
            var firstPatternPartHasBeenDetected = false
            var lastPatternIsAsterisk = false
            var currentPatternPartIndex = 0
            var firstElementIndexDetected = -1
            val lastElementIndex = epath.size - 1
            for (elementIndex : 0 ..< epath.size) {// Hello, C ...
                val element = epath.get(elementIndex)
                val elementName = element.object.getAttributeValue('name')

                if(currentPatternPartIndex < hiddenPattern.size) {
                    val currentPatternPart = hiddenPattern.get(currentPatternPartIndex)
                    lastPatternIsAsterisk = currentPatternPart == '*'
                    val elementNameContainsCurrentPatternPart = elementName.contains(currentPatternPart)
    
                    if(firstPatternPartHasBeenDetected || elementNameContainsCurrentPatternPart) {
                        if(elementNameContainsCurrentPatternPart) {
                            if (!firstPatternPartHasBeenDetected) {
                                firstElementIndexDetected = elementIndex
                                firstPatternPartHasBeenDetected = true
                            }
                            currentPatternPartIndex += 1
                        }
    
                        if (newPattern == null) {
                            newPattern = new StringBuilder
                        }
    
                        newPattern.append(elementName).append('/')
    
                        if (elementIndex == lastElementIndex &&
                            ((elementNameContainsCurrentPatternPart && currentPatternPartIndex == hiddenPattern.size) ||
                                lastPatternIsAsterisk
                            )
                        ) {
                            if(element.hasDomainPrimitiveTypeElement) {
                                newPattern.append('value')
                            }
                            else {
                                newPattern.deleteCharAt(newPattern.length - 1)
                            }
    
                            if(dictionary.keepExtraTop > 0 && firstElementIndexDetected != -1 && firstElementIndexDetected > 0) {
                                var extraElementIndexToAppendOnTop = firstElementIndexDetected - dictionary.keepExtraTop
                                extraElementIndexToAppendOnTop = if (extraElementIndexToAppendOnTop < 0) 0 else extraElementIndexToAppendOnTop
    
                                val extraTopElements = epath.subList(extraElementIndexToAppendOnTop, firstElementIndexDetected)
                                val patternWithExtraElements = '''«FOR extraElement : extraTopElements SEPARATOR '/'»«extraElement.object.getAttributeValue('name')»«ENDFOR»/«newPattern.toString»'''
                                toHide.put(operationName, operationElementType -> patternWithExtraElements)
                            }
                            else {
                                toHide.put(operationName, operationElementType -> newPattern.toString)
                            }
                        }
                }
                }
            }
        }
        // ###########
    }

    val static P_SUPPLIER = new Suppliers.ListSupplier<Pair<String, String>>

    def getToMask() {
        toMask
    }

    def getToHide() {
        toHide
    }
}
