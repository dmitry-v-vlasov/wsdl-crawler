package org.whitehotstone.security.wsdl.crawler.model

import com.google.common.collect.Multimap
import org.whitehotstone.security.wsdl.crawler.common.Suppliers.ListSupplier
import org.whitehotstone.security.wsdl.crawler.xml.StdNamespace
import java.util.List
import java.util.Map
import org.jdom2.Document
import org.jdom2.Element
import org.jdom2.Namespace

import static com.google.common.collect.Multimaps.*
import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.*

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.stdNamespaces
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.userNamespaces
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.userNamespacesIntroduced
import static extension org.whitehotstone.security.wsdl.crawler.xml.XPaths.xpath
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.aname
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.eparent
import java.nio.file.Path
import java.nio.file.Files

class WsdlAdapter {
    static val ELEMENT_LIST_SUPPLIER = new ListSupplier<Element>()
    static val XSD_SCHEMA_LIST_SUPPLIER = new ListSupplier<XsdAdapter>()

    Path location

    Document document
    Element definitions
    Map<StdNamespace, Namespace> npace
    String targetNamespace
    Map<String, Element> service = newTreeMap(null, emptyList)
    Map<String, Element> binding = newTreeMap(null, emptyList)
    Map<String, Element> portType = newTreeMap(null, emptyList)
    Map<String, Element> message = newTreeMap(null, emptyList)
    Multimap<String, Element> messagePart = newListMultimap(newTreeMap(null, <Pair<String, List<Element>>>emptyList), ELEMENT_LIST_SUPPLIER)

    Multimap<Namespace, XsdAdapter> schemas = newListMultimap(
        newTreeMap([n1, n2|n1.URI.compareTo(n2.URI)], <Pair<Namespace, List<XsdAdapter>>>emptyList), XSD_SCHEMA_LIST_SUPPLIER)

    new(Document document, Path path) {
        document.checkNotNull()
        path.checkNotNull()
        Files.isRegularFile(path).checkArgument()

        this.location = path.toRealPath()

        (document.rootElement.name == 'definitions' && document.rootElement.namespace == WSDL.ns).checkArgument(
            'The given document is not a WSDL one.')
        this.document = document
        this.definitions = document.rootElement
        this.npace = definitions.stdNamespaces
        this.targetNamespace = definitions.getAttributeValue('targetNamespace')

        // ###
        val serviceList = #[npace.get(WSDL) -> 'service'].xpath.evaluate(this.definitions)
        (!serviceList.nullOrEmpty).checkState()
        service.putAll(serviceList.toMap[aname])
        // ###
        val bindingList = #[npace.get(WSDL) -> 'binding'].xpath.evaluate(this.definitions)
        (!bindingList.nullOrEmpty).checkState()
        binding.putAll(bindingList.toMap[aname])
        // ###
        val portTypeList = #[npace.get(WSDL) -> 'portType'].xpath.evaluate(this.definitions)
        (!portTypeList.nullOrEmpty).checkState()
        portType.putAll(portTypeList.toMap[aname])
        // ###
        val messageList = #[npace.get(WSDL) -> 'message'].xpath.evaluate(this.definitions)
        (!messageList.nullOrEmpty).checkState()
        message.putAll(messageList.toMap[aname])
        // ###
        val messagePartList = #[npace.get(WSDL) -> 'message', npace.get(WSDL) -> 'part'].xpath.evaluate(this.definitions)
        (!messagePartList.nullOrEmpty).checkState()
        messagePartList.forEach[if (eparent != null) messagePart.put(eparent.aname, it)]

        // ###
        val schemaList = #[npace.get(WSDL) -> 'types', npace.get(XSD) -> 'schema'].xpath.evaluate(this.definitions)
        (!schemaList.nullOrEmpty).checkState()
        schemaList.forEach [ schema |
            val targetNamespace = schema.getAttributeValue('targetNamespace')
            (targetNamespace == null || !targetNamespace.trim.empty).checkState('The attribute targetNamespace value cannot be an empty string')
            val schemaUserNs = schema.userNamespacesIntroduced()
            if(!(targetNamespace != null || (targetNamespace == null && schemaUserNs != null && schemaUserNs.size == 1))) {
                return
            }
            (targetNamespace != null || (targetNamespace == null && schemaUserNs != null && schemaUserNs.size == 1)).checkState(
                'Define a targetNamespace or a single user xmlns attribute.')
            val schemaNamespaceURI = targetNamespace ?: schemaUserNs.firstKey

            // TODO: take the sibling schema namespaces into account
            val inheritedNamespaces = schema.userNamespaces
            schemas.put(inheritedNamespaces.get(schemaNamespaceURI) ?: Namespace.getNamespace(schemaNamespaceURI),
                new XsdAdapter(schema, location.parent, this))
        ]
    }

    def getDefinitions() {
        definitions
    }

    def getTargetNamespace() {
        targetNamespace
    }

    def getService() {
        service
    }

    def getBinding() {
        binding
    }

    def getPortType() {
        portType
    }

    def getMessage() {
        message
    }

    def getMessagePart() {
        messagePart
    }

    def getSchemas() {
        schemas
    }

    def getLocation() {
        location
    }
}
