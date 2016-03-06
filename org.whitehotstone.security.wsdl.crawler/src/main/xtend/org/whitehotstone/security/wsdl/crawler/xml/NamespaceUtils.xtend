package org.whitehotstone.security.wsdl.crawler.xml

import java.util.Comparator
import org.jdom2.Element
import org.jdom2.Namespace

import static com.google.common.collect.Maps.*

import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.collect.Maps.newEnumMap
import static extension org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.existsStdNs
import static extension org.whitehotstone.security.wsdl.crawler.xml.StdNamespace.stdNamespace

class NamespaceUtils {
    public static val Comparator<Namespace> NAMESPACE_COMPARATOR = [ Namespace ns1, Namespace ns2 |
        ns1.checkNotNull()
        ns2.checkNotNull()
        ns1.URI.compareTo(ns2.URI)
    ]

    def static stdNamespaces(Element element) {
        element.namespacesInScope.filter[existsStdNs].toMap[stdNamespace].newEnumMap
    }

    def static userNamespaces(Element element) {
        val nsMap = element.namespacesInScope.filter[!existsStdNs].toMap[URI]
        val userNamespaces = <String, Namespace>newTreeMap
        userNamespaces.putAll(nsMap)
        userNamespaces
    }

    def static userNamespacesIntroduced(Element element) {
        var nsMap = element.namespacesIntroduced.filter[!existsStdNs].toMap[URI]
        val userNamespaces = <String, Namespace>newTreeMap
        userNamespaces.putAll(nsMap)
        userNamespaces
    }
}
