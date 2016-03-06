package org.whitehotstone.security.wsdl.crawler.error

import java.lang.RuntimeException

class SensitiveDataToolException extends RuntimeException {
    new(String message) {
        super(message)
    }

    new(String message, Throwable cause) {
        super(message, cause)
    }

    def static toolerror(String message) {
        new SensitiveDataToolException(message)
    }
}
