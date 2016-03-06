package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.IParameterValidator
import com.beust.jcommander.ParameterException
import java.nio.file.FileSystems
import java.nio.file.InvalidPathException
import static extension java.nio.file.Files.isRegularFile

class StringPathFileValidator implements IParameterValidator {

    static val FILE_SYSTEM = FileSystems.^default

    override validate(String name, String value) throws ParameterException {
        try {
            val path = FILE_SYSTEM.getPath(value)
            if (!path.regularFile) {
                throw new ParameterException('''The path '«path»' is not a directory.''')
            }
        } catch (InvalidPathException exception) {
            throw new ParameterException(exception)
        }
    }

}