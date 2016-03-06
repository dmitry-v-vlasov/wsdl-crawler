package org.whitehotstone.security.wsdl.crawler.xml

import java.util.List
import org.jdom2.Namespace
import org.jdom2.filter.Filters
import org.jdom2.xpath.XPathBuilder
import org.jdom2.xpath.XPathFactory

import static org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.*

import static extension com.google.common.base.Preconditions.checkArgument

class XPaths {
    static val XPATH_FACTORY = XPathFactory.instance

    // =========================================================================================================================
    def static xpath(List<Pair<Namespace, String>> elements) {
        elements.xpath(null, false, false)
    }

    def static xpath(List<Pair<Namespace, String>> elements, Pair<String, String> attribute) {
        elements.xpath(attribute, false, false)
    }

    def static xpathChildren(List<Pair<Namespace, String>> elements) {
        elements.xpath(null, true, false)
    }

    def static xpathChildren(List<Pair<Namespace, String>> elements, Pair<String, String> attribute) {
        elements.xpath(attribute, true, false)
    }

    // =========================================================================================================================
    def static xpathr(List<Pair<Namespace, String>> elements) {
        elements.xpath(null, false, true)
    }

    def static xpathr(List<Pair<Namespace, String>> elements, Pair<String, String> attribute) {
        elements.xpath(attribute, false, true)
    }

    def static xpathrChildren(List<Pair<Namespace, String>> elements) {
        elements.xpath(null, true, true)
    }

    def static xpathrChildren(List<Pair<Namespace, String>> elements, Pair<String, String> attribute) {
        elements.xpath(attribute, true, true)
    }

    // =========================================================================================================================
    def private static xpath(List<Pair<Namespace, String>> elements, Pair<String, String> attribute, boolean oneLevel, boolean relative) {
        (!elements.nullOrEmpty).checkArgument('XPath cannot be constructed with null or empty element list.')
        val xpathSB = new StringBuilder
        if (relative) {
            xpathSB.append('.')
        }
        if (!oneLevel) {
            xpathSB.append('/')
        }
        val namespaceList = <Namespace>newArrayList()
        elements.forEach [
            val namespaceExpression = if (key == null || key == NO_NAMESPACE.ns) '' else ''' and namespace-uri() = '«key.URI»' '''
            val attributeExpression = if (attribute == null) '' else ''' and @«attribute.key»='«attribute.value»' '''
            xpathSB.append('''/*[local-name() = '«value»'«namespaceExpression»«attributeExpression»]''')
            if (key != null && !key.prefix.nullOrEmpty) {
                namespaceList.add(key)
            }
        ]
        val builder = new XPathBuilder(xpathSB.toString(), Filters.element)
        if (!namespaceList.nullOrEmpty) {
            builder.namespaces = namespaceList
        }
        builder.compileWith(XPATH_FACTORY)
    }
}
