package org.whitehotstone.security.wsdl.crawler.handling

import com.google.inject.Inject
import org.whitehotstone.security.wsdl.crawler.handling.Functions.Name
import org.whitehotstone.security.wsdl.crawler.model.SourceType

import static extension com.google.common.base.Preconditions.checkNotNull
import java.nio.file.Path
import java.util.List
import org.whitehotstone.security.wsdl.crawler.model.ServiceDefinitionMiningResult
import java.util.Map

class FunctionsFactory {
    @Inject
    Functions functions

    def createSource(SourceType sourceType) {
        sourceType.checkNotNull
        switch(sourceType) {
            case WSDL: functions.get(Name.WSDL_SOURCE) as (Path)=>ServiceDefinitionMiningResult
            case JAVA: null
            default: null
        }
    }

    def createSourceResult(SourceType sourceType) {
        sourceType.checkNotNull
        switch(sourceType) {
            case WSDL: functions.get(Name.WSDL_SOURCE_RESULT) as (ServiceDefinitionMiningResult)=>ServiceDefinitionMiningResult
            case JAVA: null
            default: null
        }
    }

    def createSourceResults(SourceType sourceType) {
        sourceType.checkNotNull
        switch(sourceType) {
            case WSDL: functions.get(Name.WSDL_SOURCE_RESULTS) as (List<ServiceDefinitionMiningResult>)=>Map<String, String>
            case JAVA: null
            default: null
        }
    }
}
