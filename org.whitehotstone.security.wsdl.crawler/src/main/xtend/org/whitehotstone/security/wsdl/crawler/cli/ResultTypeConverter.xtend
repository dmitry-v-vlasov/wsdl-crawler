package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.converters.BaseConverter
import org.whitehotstone.security.wsdl.crawler.model.ResultType

import static org.whitehotstone.security.wsdl.crawler.model.ResultType.REPORT
import static org.whitehotstone.security.wsdl.crawler.model.ResultType.SQL_CONFIG
import static org.whitehotstone.security.wsdl.crawler.model.ResultType.UNSUPPORTED

import static extension com.google.common.base.Preconditions.checkNotNull

class ResultTypeConverter extends BaseConverter<ResultType> {

    new(String optionName) {
        super(optionName)
    }

    override convert(String value) {
        value.checkNotNull('Null parameter value!')
        switch (value) {
            case 'sql-config': return SQL_CONFIG
            case 'report': return REPORT
            default: return UNSUPPORTED
        }
    }
}
