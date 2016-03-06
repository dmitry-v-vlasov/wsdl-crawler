package org.whitehotstone.security.wsdl.crawler.model.configuration.generator;

import javax.annotation.Generated;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;


@Generated("org.whitehotstone.security.wsdl")
public class SqlConfig {

    @SerializedName("wsdl")
    @Expose
    private WsdlSqlConfig wsdl;

    public WsdlSqlConfig getWsdl() {
        return wsdl;
    }
    public void setWsdl(WsdlSqlConfig wsdl) {
        this.wsdl = wsdl;
    }
    public void withWsdl(WsdlSqlConfig wsdl) {
        this.wsdl = wsdl;
    }
}
