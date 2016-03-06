package org.whitehotstone.security.wsdl.crawler.model.configuration.sources;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class Sources {

    @SerializedName("wsdl")
    @Expose
    private WsdlSources wsdl;

    public WsdlSources getWsdl() {
        return wsdl;
    }
    public void setWsdl(WsdlSources wsdl) {
        this.wsdl = wsdl;
    }
    public Sources withWsdl(WsdlSources wsdl) {
        this.wsdl = wsdl;
        return this;
    }

}
