package org.whitehotstone.security.wsdl.crawler.model

import java.util.List
import java.util.ArrayList

class ServiceDefinitionMiningResult {
    WsdlAdapter wsdl

    List<ServiceMiningResult> results = new ArrayList

    new(WsdlAdapter wsdl) {
        this.wsdl = wsdl
    }

    def addServiceMiningResult(ServiceMiningResult result) {
        results.add(result)
    }

    def getServiceMiningResults() {
        results.unmodifiableView
    }

    def getTargetNamespace() {
        wsdl.targetNamespace
    }

    def getWsdlLocation() {
        wsdl.location
    }

    def getWsdl() {
        wsdl
    }
}
