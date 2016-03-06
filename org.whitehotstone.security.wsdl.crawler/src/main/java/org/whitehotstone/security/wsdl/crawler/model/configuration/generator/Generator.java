package org.whitehotstone.security.wsdl.crawler.model.configuration.generator;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class Generator {

    @SerializedName("sql-config")
    @Expose
    private SqlConfig sqlConfig;

    public SqlConfig getSqlConfig() {
        return sqlConfig;
    }
    public void setSqlConfig(SqlConfig sql) {
        this.sqlConfig = sql;
    }
    public Generator withSqlConfig(SqlConfig sql) {
        this.sqlConfig = sql;
        return this;
    }
}
