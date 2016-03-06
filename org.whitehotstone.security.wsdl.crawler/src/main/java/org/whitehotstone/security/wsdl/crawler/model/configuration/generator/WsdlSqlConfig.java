package org.whitehotstone.security.wsdl.crawler.model.configuration.generator;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class WsdlSqlConfig {

    @SerializedName("service-mappings")
    @Expose
    private List<WsdlServiceMapping> serviceMappings = new ArrayList<>();

    @SerializedName("config-names")
    @Expose
    private ConfigNames configNames;

    public List<WsdlServiceMapping> getServiceMappings() {
        return serviceMappings;
    }
    public void setServiceNameMappings(List<WsdlServiceMapping> serviceMappings) {
        this.serviceMappings = serviceMappings;
    }
    public WsdlSqlConfig withServiceMappings(List<WsdlServiceMapping> serviceMappings) {
        this.serviceMappings = serviceMappings;
        return this;
    }

    public ConfigNames getConfigNames() {
        return configNames;
    }
    public void setConfigNames(ConfigNames configNames) {
        this.configNames = configNames;
    }
    public WsdlSqlConfig withConfigNames(ConfigNames configNames) {
        this.configNames = configNames;
        return this;
    }
}
