package org.whitehotstone.security.wsdl.crawler.xml;

import java.util.Map;

import org.jdom2.Namespace;

import static org.jdom2.Namespace.getNamespace;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Maps.newTreeMap;

import static org.whitehotstone.security.wsdl.crawler.xml.NamespaceUtils.NAMESPACE_COMPARATOR;

public enum StdNamespace {
    WSDL(getNamespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")),
    XSD(getNamespace("xsd", "http://www.w3.org/2001/XMLSchema")),
    WSA_2003(getNamespace("wsa",
            "http://schemas.xmlsoap.org/ws/2003/03/addressing")),
    WSA_2004(getNamespace("wsa",
            "http://schemas.xmlsoap.org/ws/2004/08/addressing")),
    WSA_2005(getNamespace("wsa", "http://www.w3.org/2005/08/addressing")),
    SOAP(getNamespace("soap", "http://schemas.xmlsoap.org/wsdl/soap/")),
    SOAPENV11(getNamespace("soapenv11",
            "http://schemas.xmlsoap.org/soap/envelope/")),
    SOAPENV12(getNamespace("soapenv12",
            "http://www.w3.org/2003/05/soap-envelope")),
    SOAPMIME(getNamespace("mime", "http://schemas.xmlsoap.org/wsdl/mime/")),
    SOAPENC11(getNamespace("soapenc11",
            "http://schemas.xmlsoap.org/soap/encoding/")),
    SOAPENC12(getNamespace("soapenc12",
            "http://www.w3.org/2003/05/soap-encoding")),
    SOAP_HTTP(getNamespace("soap-http", "http://schemas.xmlsoap.org/wsdl/http/")),
    MAVEN(getNamespace("mvn", "http://maven.apache.org/POM/4.0.0")),
    NO_NAMESPACE(Namespace.NO_NAMESPACE);

    private static final Map<Namespace, StdNamespace> STD_NAMESPACE_ACCESS = newTreeMap(NAMESPACE_COMPARATOR);
    static {
        for (StdNamespace stdNs : values()) {
            STD_NAMESPACE_ACCESS.put(stdNs.getNs(), stdNs);
        }
    }

    public static StdNamespace stdNamespace(Namespace ns) {
        return STD_NAMESPACE_ACCESS.get(ns);
    }

    public static boolean existsStdNs(Namespace ns) {
        checkNotNull(ns);
        return STD_NAMESPACE_ACCESS.containsKey(ns);
    }

    private StdNamespace(Namespace namespace) {
        this.namespace = namespace;
    }

    private Namespace namespace;

    public Namespace getNs() {
        return namespace;
    }
}
