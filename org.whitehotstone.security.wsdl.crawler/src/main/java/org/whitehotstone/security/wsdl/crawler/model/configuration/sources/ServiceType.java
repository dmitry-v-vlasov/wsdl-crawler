package org.whitehotstone.security.wsdl.crawler.model.configuration.sources;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class ServiceType {
    @SerializedName("service-type")
    @Expose
    private String serviceType;

    @SerializedName("tags")
    @Expose
    private List<String> tags = new ArrayList<>();

    public String getServiceType() {
        return serviceType;
    }
    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }
    public ServiceType withServiceType(String serviceType) {
        this.serviceType = serviceType;
        return this;
    }

    public List<String> getTags() {
        return tags;
    }
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    public ServiceType withTags(List<String> tags) {
        this.tags = tags;
        return this;
    }
}
