package org.whitehotstone.security.wsdl.crawler.model

import org.whitehotstone.security.wsdl.crawler.xml.StdNamespace
import java.nio.file.Files
import java.nio.file.Path
import java.util.Map
import java.util.Set
import org.jdom2.Document
import org.jdom2.Element
import org.jdom2.Namespace

import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.*

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.stdNamespaces
import static extension org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.userNamespaces
import static extension org.whitehotstone.security.wsdl.crawler.xml.XPaths.xpath
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.aname
import static extension org.whitehotstone.security.wsdl.crawler.xml.XmlUtils.loadXml

class XsdAdapter {

    Path context

    Document document
    Element schema
    WsdlAdapter wsdl

    Map<StdNamespace, Namespace> npace
    Map<String, Namespace> unpace
    Set<Namespace> unpaces

    Map<String, Element> elements = newTreeMap(null, emptyList)
    Map<Namespace, Element> imports = newTreeMap([n1, n2|n1.URI.compareTo(n2.URI)], emptyList)
    Map<Namespace, XsdAdapter> externalSchemas = newTreeMap([n1, n2|n1.URI.compareTo(n2.URI)], emptyList)

    new(Document schema, Path path) {
        this(schema, schema.rootElement, path, null)
    }

    new(Element schema, Path path, WsdlAdapter wsdl) {
        this(schema?.document, schema, path, wsdl)
    }

    private new(Document document, Element schema, Path path, WsdlAdapter wsdl) {
        schema.checkNotNull
        document.checkNotNull
        path.checkNotNull
        Files.isDirectory(path).checkArgument
        this.context = path.toRealPath
        this.document = document
        this.schema = schema
        this.wsdl = wsdl

        npace = this.schema.stdNamespaces
        unpace = this.schema.userNamespaces
        unpaces = unpace.values.toSet

        val importList = #[npace.get(XSD) -> 'import'].xpath.evaluate(this.schema)
        imports.putAll(importList?.filter[!(getAttributeValue('schemaLocation').nullOrEmpty)].toMap [
            val uri = getAttributeValue('namespace')
            val ns = unpace.get(uri) ?: {npace.values.findFirst[URI == uri]}
            ns.checkNotNull;
            ns
        ])

        val elementList = this.schema.children.filter[name == 'element']
        elements.putAll(elementList?.toMap[aname])
    }

    def fetchImportBy(Namespace namespace) {
        namespace.checkNotNull;
        (unpaces.contains(namespace) || namespace == StdNamespace.WSA_2004.ns || namespace == StdNamespace.WSA_2003.ns || namespace == StdNamespace.WSA_2005.ns).checkArgument()
        (imports.containsKey(namespace) || (wsdl != null && wsdl.schemas.containsKey(namespace))).checkArgument
        if(imports.containsKey(namespace)) {
            return externalSchemas.get(namespace) ?: {
                val schemaLocation = context.resolve(imports.get(namespace).getAttributeValue('schemaLocation'))
                Files.isRegularFile(schemaLocation).checkState
                val newSchemaDocument = new XsdAdapter(schemaLocation.loadXml, schemaLocation.parent)
                externalSchemas.put(namespace, newSchemaDocument)
                newSchemaDocument
            }
        }
        else if(wsdl != null && wsdl.schemas.containsKey(namespace)) {
            (wsdl.schemas.get(namespace).size == 1).checkState
            return wsdl.schemas.get(namespace).get(0)
        }
        else {
            return null
        }
    }

    def getSchemaStdNamespaces() {
        npace.unmodifiableView
    }

    def getSchemaUserNamespaces() {
        unpace.unmodifiableView
    }

    def getSchema() {
        schema
    }

    def getImports() {
        imports.unmodifiableView
    }

    def fetchElementBy(String name) {
        elements.get(name)
    }
}
