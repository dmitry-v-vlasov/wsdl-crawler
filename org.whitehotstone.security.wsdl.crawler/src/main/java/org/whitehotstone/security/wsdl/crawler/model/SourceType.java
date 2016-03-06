package org.whitehotstone.security.wsdl.crawler.model;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Generated;

@Generated("org.whitehotstone.security.wsdl")
public enum SourceType {
    WSDL("wsdl", ".wsdl"),
    JAVA("java", ".java"),
    UNSUPPORTED("unsupported", ".unsupported");
    private static Map<String, SourceType> constants = new HashMap<String, SourceType>();
    static {
        for (SourceType c : values()) {
            constants.put(c.value, c);
        }
    }

    private SourceType(String value, String extension) {
        this.value = value;
        this.extension = extension;
    }

    private final String value;
    private String extension;

    @Override
    public String toString() {
        return this.value;
    }

    public String getExtension() {
        return extension;
    }

    public static SourceType fromValue(String value) {
        SourceType constant = constants.get(value);
        if (constant == null) {
            throw new IllegalArgumentException(value);
        } else {
            return constant;
        }
    }
}
