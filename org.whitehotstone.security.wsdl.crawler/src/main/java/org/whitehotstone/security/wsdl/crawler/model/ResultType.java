package org.whitehotstone.security.wsdl.crawler.model;

public enum ResultType {
    SQL_CONFIG("sql-config"),
    REPORT("report"),
    UNSUPPORTED("unsupported");

    private String name;

    private ResultType(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
