package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.converters.BaseConverter
import org.whitehotstone.security.wsdl.crawler.model.SourceType

import static org.whitehotstone.security.wsdl.crawler.model.SourceType.WSDL
import static org.whitehotstone.security.wsdl.crawler.model.SourceType.JAVA
import static org.whitehotstone.security.wsdl.crawler.model.SourceType.UNSUPPORTED

import static extension com.google.common.base.Preconditions.checkNotNull

class SourceTypeConverter extends BaseConverter<SourceType> {

    new(String optionName) {
        super(optionName)
    }

    override convert(String value) {
        value.checkNotNull('Null parameter value!')
        switch (value) {
            case 'wsdl': return WSDL
            case 'java': return JAVA
            default: return UNSUPPORTED
        }
    }

}