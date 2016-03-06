package org.whitehotstone.security.wsdl.crawler.xml

import com.google.common.base.Splitter
import java.nio.charset.StandardCharsets
import java.nio.file.Path
import javax.xml.stream.XMLInputFactory
import org.jdom2.Element
import org.jdom2.Namespace
import org.jdom2.input.StAXStreamBuilder

import static java.nio.file.Files.*

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState

class XmlUtils {
    static val XML_FACTORY = XMLInputFactory.newFactory
    static val NS_SPLITTER = Splitter.on(':').omitEmptyStrings.trimResults

    def static aname(Element element) {
        element.checkNotNull()
        val name = element.getAttribute('name')
        name.checkNotNull
        name.value
    }

    def static aname(Element element, Namespace ns) {
        element.checkNotNull()
        val name = element.getAttribute('name', ns)
        name.checkNotNull
        name.value
    }

    def static eparent(Element element) {
        element.checkNotNull()
        if (element.parent.class == Element)
            element.parent as Element
        else
            null
    }

    def static ereference(Element element, String attributeName) {
        element.checkNotNull()
        (!attributeName.nullOrEmpty).checkArgument
        if (element.getAttribute(attributeName) == null) {
            return null
        }
        val referenceValue = element.getAttributeValue(attributeName)
        (!referenceValue.nullOrEmpty).checkState

        val refElements = NS_SPLITTER.split(referenceValue)
        (!refElements.empty).checkState()
        (refElements.size <= 2).checkState

        val ns = element.namespacesInScope
        val defaultNs = ns.findFirst[prefix.nullOrEmpty]
        val namespace = if (refElements.size == 1) defaultNs ?: Namespace.NO_NAMESPACE else ns.findLast[prefix == refElements.head]
        namespace.checkNotNull
        namespace -> refElements.last
    }

    def static loadXml(Path path) {
        (new StAXStreamBuilder).build(XML_FACTORY.createXMLStreamReader(newBufferedReader(path, StandardCharsets.UTF_8)))
    }
}
