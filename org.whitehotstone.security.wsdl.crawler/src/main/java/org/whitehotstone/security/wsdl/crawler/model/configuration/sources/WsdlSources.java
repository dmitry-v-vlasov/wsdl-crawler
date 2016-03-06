package org.whitehotstone.security.wsdl.crawler.model.configuration.sources;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class WsdlSources {

    @SerializedName("service-types")
    @Expose
    private List<ServiceType> serviceTypes = new ArrayList<>();

    @SerializedName("service-definitions")
    @Expose
    private List<ServiceDefinition> serviceDefinitions = new ArrayList<>();

    public List<ServiceType> getServiceTypes() {
        return serviceTypes;
    }
    public void setServiceTypes(List<ServiceType> serviceTypes) {
        this.serviceTypes = serviceTypes;
    }
    public WsdlSources withServiceTypes(List<ServiceType> serviceTypes) {
        this.serviceTypes = serviceTypes;
        return this;
    }

    public List<ServiceDefinition> getServiceDefinitions() {
        return serviceDefinitions;
    }
    public void setServiceDefinitions(List<ServiceDefinition> serviceDefinitions) {
        this.serviceDefinitions = serviceDefinitions;
    }
    public WsdlSources withServiceDefinitions(List<ServiceDefinition> serviceDefinitions) {
        this.serviceDefinitions = serviceDefinitions;
        return this;
    }
}
