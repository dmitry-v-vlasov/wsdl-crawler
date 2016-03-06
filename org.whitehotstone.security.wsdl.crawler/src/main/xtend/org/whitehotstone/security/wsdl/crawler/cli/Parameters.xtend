package org.whitehotstone.security.wsdl.crawler.cli

import com.beust.jcommander.Parameter
import org.whitehotstone.security.wsdl.crawler.model.ResultType
import org.whitehotstone.security.wsdl.crawler.model.SourceType
import java.nio.file.Path

@com.beust.jcommander.Parameters(separators='=')
class Parameters {
    @Parameter(names=#[
        '-d',
        '--directory-path'
    ], required=true, arity=1, converter=StringPathConverter, validateWith=StringPathDirectoryValidator, description='The root directory to start sources look-up.')
    public Path directory

    @Parameter(names=#[
        '-s',
        '--source-type'
    ], required=true, arity=1, converter=SourceTypeConverter, validateWith=SourceTypeValidator, description='The kind of sources to investigate; Supported values: wsdl, java.')
    public SourceType sourceType

    @Parameter(names=#[
        '-r',
        '--result-type'
    ], required=true, arity=1, converter=ResultTypeConverter, validateWith=ResultTypeValidator, description='The sort of textual result; Supported values: sql-config, report')
    public ResultType resultType

    @Parameter(names=#[
        '-o',
        '--output-path'
    ], required=true, arity=1, converter=StringPathConverter, description='The file output path to write the result.')
    public Path outputPath

    @Parameter(names=#[
        '-c',
        '--configuration-path'
    ], required=false, arity=1, converter=StringPathConverter, validateWith=StringPathFileValidator, description="The path to your custom configuration file; Default one is called 'config.json' with the classpath '/META-INF/org.whitehotstone.security.wsdl.crawler/config.json'.")
    public Path config

    @Parameter(names=#['-h', '--help'], required=false, arity=0, help=true)
    public boolean help
}
