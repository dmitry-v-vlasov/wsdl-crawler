package org.whitehotstone.security.wsdl.crawler.io

import com.google.common.base.Function
import org.whitehotstone.security.wsdl.crawler.logging.Markers
import java.io.IOException
import java.nio.file.FileVisitResult
import java.nio.file.Path
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.util.List

import static java.nio.file.FileVisitResult.CONTINUE

import static extension com.google.common.base.Functions.compose
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension java.nio.file.Files.isDirectory
import static extension org.slf4j.LoggerFactory.getLogger
import java.util.ArrayList

class CollectingExecutingFileVisitor<FILE_RESULT_TYPE, RESULT_TYPE> extends SimpleFileVisitor<Path> {

    static val LOGGER = CollectingExecutingFileVisitor.logger
    static val MARKER = Markers.FILE_VISITOR.instance

    String fileExtension
    Function<Path, RESULT_TYPE> resultHandling

    List<RESULT_TYPE> results = new ArrayList<RESULT_TYPE>

    new(String fileExtension, Function<Path, FILE_RESULT_TYPE> fileHandling, Function<FILE_RESULT_TYPE, RESULT_TYPE> fileResultHandling) {
        fileExtension.checkNotNull('Specify file extension!')
        fileHandling.checkNotNull('The fileHandling cannot be null.')
        fileResultHandling.checkNotNull('The fileResultHandling cannot be null.')
        this.fileExtension = fileExtension
        resultHandling = fileResultHandling.compose(fileHandling)
    }

    override FileVisitResult visitFile(Path file, BasicFileAttributes attributes) {
        file.checkNotNull('The file cannot be null here.')
        if (file.directory) {
            return CONTINUE
        }
        if(!file.toString.toLowerCase.endsWith(fileExtension)) {
            return CONTINUE
        }
        attributes.checkNotNull('''The attributes of the file '«file»' are null occasionally.''')
        file.handle(attributes)
        CONTINUE
    }

    override FileVisitResult visitFileFailed(Path file, IOException error) {
        file.checkNotNull('The file cannot be null here.')
        LOGGER.error(MARKER, '''Unable to handle the file '«file»'.''')
        throw error
    }

    def private void handle(Path file, BasicFileAttributes attributes) {
        val result = resultHandling.apply(file)
        if(result != null) {
            results.add(result)
        }
    }

    def getResults() {
        results.unmodifiableView
    }

    def resetResults() {
        results.clear
    }
}
