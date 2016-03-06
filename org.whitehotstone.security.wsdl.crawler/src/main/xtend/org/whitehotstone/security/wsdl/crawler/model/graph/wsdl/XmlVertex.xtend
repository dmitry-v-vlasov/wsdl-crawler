package org.whitehotstone.security.wsdl.crawler.model.graph.wsdl

import org.whitehotstone.security.wsdl.crawler.model.graph.Vertex
import org.jdom2.Element

import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.ereference
import org.jdom2.Namespace
import java.util.UUID

import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.XSD

class XmlVertex extends Vertex<Element> {

    Pair<Namespace, String> elementDefinitionReference
    boolean primitive
    boolean domainPrimitive
    boolean typedElement
    boolean anonTypedElement
    boolean referencedElement
    boolean referencingElement
    boolean operationElement

    boolean inputElement
    boolean outputElement

    boolean messageElement
    boolean partElement

    boolean typeElement

    String elementId

    new(Element object) {
        this(object, null)
    }

    new(Element object, Pair<Namespace, String> oref) {
        super(object)
        if (object.name == 'simpleType' || object.name == 'complexType') {
            if (this.object.getAttributeValue('name') != null) {
                elementId = '''«IF oref == null»«ELSE»{«oref.key.URI»}«ENDIF»«this.object.getAttributeValue('name')»'''
            }
            else {
                elementId = if (oref != null && oref.value.startsWith('anon_')) oref.value else '''anon_«UUID.randomUUID»'''
            }
            typeElement = true
        }
        else if(object.name == 'element') {
            if (object.getAttributeValue('type') != null) {
                elementDefinitionReference = object.ereference('type')
                typedElement = true
                if (XSD_PRIMITIVES.contains(elementDefinitionReference.value)) {
                    primitive = true
                }
                else if (DOMAIN_PRIMITIVES.contains(elementDefinitionReference.value)) {
                    domainPrimitive = true
                }
            }
            else if(object.getAttributeValue('ref') != null) {
                elementDefinitionReference = object.ereference('ref')
                referencedElement = true
            }
            else if(object.getChild('complexType', XSD.ns) != null) {
                val complexType = object.getChild('complexType', XSD.ns)
                if(complexType.getAttributeValue('name').nullOrEmpty) {
                    elementDefinitionReference = XSD.ns -> '''anon_«UUID.randomUUID»'''
                    anonTypedElement = true
                    typedElement = true
                }
            }
            else if(object.getChild('simpleType', XSD.ns) != null) {
                val simpleType = object.getChild('simpleType', XSD.ns)
                if(simpleType.getAttributeValue('name').nullOrEmpty) {
                    elementDefinitionReference = XSD.ns -> '''anon_«UUID.randomUUID»'''
                    anonTypedElement = true
                    typedElement = true
                }
            }
            val name = object.getAttributeValue('name')
            val ref = this.elementDefinitionReference
            elementId = '''«name»_«IF ref == null»«IF oref == null»«ELSE»{«oref.key.URI»}«oref.value»«ENDIF»«ELSE»{«ref.key»}«ref.value»«ENDIF»'''
        }
        else if(object.name == 'operation') {
            operationElement = true
            elementId = object.getAttributeValue('name')
        }
        else if(object.name == 'input') {
            inputElement = true
            elementId = '''«object.getAttributeValue('message')»«IF object.getAttributeValue('name') == null»«ELSE»#«object.getAttributeValue('message')»«ENDIF»'''
        }
        else if(object.name == 'output') {
            outputElement = true
            elementId = '''«object.getAttributeValue('message')»«IF object.getAttributeValue('name') == null»«ELSE»#«object.getAttributeValue('message')»«ENDIF»'''
        }
        else if(object.name == 'message') {
            messageElement = true
            elementId = object.getAttributeValue('name')
        }
        else if(object.name == 'part') {
            partElement = true
            elementId = '''«object.getAttributeValue('name')»_«IF object.getAttributeValue('element') == null»null«ELSE»«object.getAttributeValue('element')»«ENDIF»'''
        }
    }

    def setReferencingElement(boolean referencingElement) {
        this.referencingElement = referencingElement
    }

    public override boolean equals(Object other) {
        if (!(other instanceof XmlVertex)) {
            return false
        }
        val otherVertex = other as XmlVertex
        if (this.index != otherVertex.index) {
            return false
        }

        val tname = this.object.name
        val oname = otherVertex.object.name

        val tns = this.object.namespace
        val ons = otherVertex.object.namespace

        if (tname != oname) {
            return false
        }
        if(tns != ons) {
            return false
        }
        if(this.elementId != otherVertex.elementId) {
            return false
        }
        if(this.hasReferencingElement != otherVertex.hasReferencingElement) {
            return false
        }
        if(this.hasReferencedElement != otherVertex.hasReferencedElement) {
            return false
        }
        if(this.hasElementDefinitionReference != otherVertex.hasElementDefinitionReference) {
            return false
        }
        if(this.hasPrimitiveTypeElement != otherVertex.hasPrimitiveTypeElement) {
            return false
        }
        if(this.hasDomainPrimitiveTypeElement != otherVertex.hasDomainPrimitiveTypeElement) {
            return false
        }
        if(this.hasTypedElement != otherVertex.hasTypedElement) {
            return false
        }
        if(this.hasAnonTypedElement != otherVertex.hasAnonTypedElement) {
            return false
        }
        if(this.hasTypeElement != otherVertex.hasTypeElement) {
            return false
        }
        if(this.hasOperationElement != otherVertex.hasOperationElement) {
            return false
        }
        if(this.hasInputElement != otherVertex.hasInputElement) {
            return false
        }
        if(this.hasOutputElement != otherVertex.hasOutputElement) {
            return false
        }
        if(this.hasMessageElement != otherVertex.hasMessageElement) {
            return false
        }
        return true
    }

    override def boolean similar(Object other) {
        if (!(other instanceof XmlVertex)) {
            return false
        }
        val otherVertex = other as XmlVertex

        val tname = this.object.name
        val oname = otherVertex.object.name

        val tns = this.object.namespace
        val ons = otherVertex.object.namespace
        if (tname != oname) {
            return false
        }
        if(tns != ons) {
            return false
        }
        if(this.elementId != otherVertex.elementId) {
            return false
        }
        if(this.hasReferencingElement != otherVertex.hasReferencingElement) {
            return false
        }
        if(this.hasReferencedElement != otherVertex.hasReferencedElement) {
            return false
        }
        if(this.hasElementDefinitionReference != otherVertex.hasElementDefinitionReference) {
            return false
        }
        if(this.hasPrimitiveTypeElement != otherVertex.hasPrimitiveTypeElement) {
            return false
        }
        if(this.hasDomainPrimitiveTypeElement != otherVertex.hasDomainPrimitiveTypeElement) {
            return false
        }
        if(this.hasTypedElement != otherVertex.hasTypedElement) {
            return false
        }
        if(this.hasAnonTypedElement != otherVertex.hasAnonTypedElement) {
            return false
        }
        if(this.hasTypeElement != otherVertex.hasTypeElement) {
            return false
        }
        if(this.hasOperationElement != otherVertex.hasOperationElement) {
            return false
        }
        if(this.hasInputElement != otherVertex.hasInputElement) {
            return false
        }
        if(this.hasOutputElement != otherVertex.hasOutputElement) {
            return false
        }
        if(this.hasMessageElement != otherVertex.hasMessageElement) {
            return false
        }
        return true
    }

    def hasElementDefinitionReference() {
        elementDefinitionReference != null
    }

    def getElementDefinitionReference() {
        elementDefinitionReference
    }

    def hasTypedElement() {
        typedElement
    }

    def hasAnonTypedElement() {
        anonTypedElement
    }

    def hasTypeElement() {
        typeElement
    }

    def hasXmlElement() {
        typedElement || referencedElement
    }

    def hasOperationElement() {
        operationElement
    }

    def hasInputElement() {
        inputElement
    }

    def hasOutputElement() {
        outputElement
    }

    def hasMessageElement() {
        messageElement
    }

    def hasPartElement() {
        partElement
    }

    def hasPrimitiveTypeElement() {
        primitive
    }

    def hasDomainPrimitiveTypeElement() {
        domainPrimitive
    }

    def hasReferencedElement() {
        referencedElement
    }

    def hasReferencingElement() {
        referencingElement
    }

    def getElementId() {
        elementId
    }

    def hasElementId() {
        elementId != null
    }
    public static val XSD_PRIMITIVES = newTreeSet(null,
                    #['string', 'boolean', 'decimal', 'integer', 'int', 'long', 'duration', 'dateTime', 'time', 'date', 'float', 'double', 'base64Binary',
                        'anyType'])
    public static val DOMAIN_PRIMITIVES = newTreeSet(null, #['myprecious', 'mylovelyprecious', 'mypeculiarprecious', 'mydelightfulprecious'])
}
