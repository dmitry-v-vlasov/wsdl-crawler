package org.whitehotstone.security.wsdl.crawler.model

import com.google.common.collect.Multimap

class ServiceMiningResult {
    String serviceName
    Multimap<String, Pair<String, String>> dataToMask
    Multimap<String, Pair<String, String>> dataToHide

    new(String serviceName, Multimap<String, Pair<String, String>> dataToMask, Multimap<String, Pair<String, String>> dataToHide) {
        this.serviceName = serviceName
        this.dataToMask = dataToMask
        this.dataToHide = dataToHide
    }

    def getServiceName() {
        serviceName
    }

    def getDataToMask() {
        dataToMask
    }

    def getDataToHide() {
        dataToHide
    }

}
