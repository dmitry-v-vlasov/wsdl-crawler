package org.whitehotstone.security.wsdl.crawler.beans

import com.google.inject.AbstractModule
import org.whitehotstone.security.wsdl.crawler.cli.Parameters
import org.whitehotstone.security.wsdl.crawler.handling.Functions
import org.whitehotstone.security.wsdl.crawler.handling.Functions.Name
import org.whitehotstone.security.wsdl.crawler.model.configuration.Configuration
import org.whitehotstone.security.wsdl.crawler.handling.FunctionsFactory

class BindingModule extends AbstractModule {

    Parameters parameters
    Configuration configuration
    val functions = new Functions

    new(Parameters parameters, Configuration configuration) {
        this.parameters = parameters
        this.configuration = configuration
    }

    override protected configure() {
        Parameters.bind.toInstance(parameters)
        Configuration.bind.toInstance(configuration)
        Functions.bind.toInstance(functions)
        FunctionsFactory.bind.toInstance(new FunctionsFactory)
    }

    def get(Name name) {
        functions.get(name)
    }
}
