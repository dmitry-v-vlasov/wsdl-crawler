package org.whitehotstone.security.wsdl.crawler.model.configuration.sources.handling;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class MergeServiceStrategy {
    @SerializedName("service-type")
    @Expose
    private String serviceType;

    @SerializedName("merge-strategies")
    @Expose
    private List<String> mergeStrategies = new ArrayList<>();

    public String getServiceType() {
        return serviceType;
    }
    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }
    public MergeServiceStrategy withServiceType(String serviceType) {
        this.serviceType = serviceType;
        return this;
    }

    public List<String> getMergeStrategies() {
        return mergeStrategies;
    }
    public void setMergeStrategies(List<String> mergeStrategies) {
        this.mergeStrategies = mergeStrategies;
    }
    public MergeServiceStrategy withMergeStrategies(List<String> mergeStrategies) {
        this.mergeStrategies = mergeStrategies;
        return this;
    }
}
