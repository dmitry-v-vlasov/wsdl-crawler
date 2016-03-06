package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.converters.BaseConverter
import java.nio.file.Path
import java.nio.file.FileSystems

class StringPathConverter extends BaseConverter<Path> {

    static val FILE_SYSTEM = FileSystems.^default

    new(String optionName) {
        super(optionName)
    }

    override convert(String value) {
        FILE_SYSTEM.getPath(value)
    }

}
