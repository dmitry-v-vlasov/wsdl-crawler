package org.whitehotstone.security.wsdl.crawler

import com.beust.jcommander.JCommander
import com.google.gson.GsonBuilder
import com.google.inject.Guice
import com.google.inject.Inject
import com.google.inject.Injector
import org.whitehotstone.security.wsdl.crawler.beans.BindingModule
import org.whitehotstone.security.wsdl.crawler.cli.Parameters
import org.whitehotstone.security.wsdl.crawler.handling.FunctionsFactory
import org.whitehotstone.security.wsdl.crawler.io.CollectingExecutingFileVisitor
import org.whitehotstone.security.wsdl.crawler.model.configuration.Configuration
import java.io.InputStreamReader
import java.nio.charset.StandardCharsets

import static extension java.nio.file.Files.newBufferedReader
import static extension java.nio.file.Files.walkFileTree
import java.nio.file.Files
import java.nio.file.StandardOpenOption

class Main {
    // static val LOGGER = Main.logger
    // static val MAIN = Markers.MAIN.instance
    // static val MAIN_EXEC = Markers.MAIN_EXEC.instance
    static var Injector INJECTOR

    def static void main(String[] arguments) {
        // *************************************************************************************************************************
        val parameters = new Parameters
        val cli = new JCommander(parameters, arguments)
        if (parameters.help) {
            cli.usage
            return
        }
        // *************************************************************************************************************************
        val gson = (new GsonBuilder).excludeFieldsWithoutExposeAnnotation.setPrettyPrinting.create
        val configuration = if (parameters.config.nullOrEmpty) {
                gson.fromJson(
                    new InputStreamReader(
                        Main.getResourceAsStream('/META-INF/org.whitehotstone.security.wsdl.crawler/config.json'), StandardCharsets.UTF_8),
                        Configuration)
            } else {
                gson.fromJson(parameters.config.newBufferedReader(StandardCharsets.UTF_8), Configuration)
            }
        // *************************************************************************************************************************
        INJECTOR = Guice.createInjector(new BindingModule(parameters, configuration))
        val main = INJECTOR.getInstance(Main)
        main.execute
    }

    @Inject
    Parameters parameters
//    @Inject
//    Configuration configuration
    @Inject
    FunctionsFactory ffactory

    def void execute() {
        val sourceVisitor = new CollectingExecutingFileVisitor(
                        parameters.sourceType.extension,
                        ffactory.createSource(parameters.sourceType),
                        ffactory.createSourceResult(parameters.sourceType))
        parameters.directory.walkFileTree(sourceVisitor)
        val results = sourceVisitor.results
        val resultsHandler = ffactory.createSourceResults(parameters.sourceType)

        val textResults = resultsHandler.apply(results)
        val mainResult = textResults.get('main')
        val extraResult = textResults.get('extra')
        //if(parameters.resultType == 'sql-config') {
            val output = parameters.outputPath
            val stream = Files.newOutputStream(output, StandardOpenOption.CREATE, StandardOpenOption.APPEND)
            if (stream != null) {
                stream.write(mainResult.bytes)
                stream.close
            }
            if(!extraResult.empty) {
                val extraOutput = parameters.outputPath.resolveSibling('''«parameters.outputPath.fileName.toString.replaceFirst('.sql', '')».properties''')
                val streamP = Files.newOutputStream(extraOutput, StandardOpenOption.CREATE, StandardOpenOption.APPEND)
                if (streamP != null) {
                    streamP.write(extraResult.bytes)
                    streamP.close
                }
            }
        //}
    }
}
