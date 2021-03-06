package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.IParameterValidator
import com.beust.jcommander.ParameterException

import static extension com.google.common.base.Preconditions.checkNotNull

class ResultTypeValidator implements IParameterValidator {

    override validate(String name, String value) throws ParameterException {
        value.checkNotNull('''The parameter '«name»' cannot have null value.''')
        switch (value) {
            case 'sql-config',
            case 'report': return
            default: throw new ParameterException('''Unsupported result format: '«value»'.''')
        }
    }

}
