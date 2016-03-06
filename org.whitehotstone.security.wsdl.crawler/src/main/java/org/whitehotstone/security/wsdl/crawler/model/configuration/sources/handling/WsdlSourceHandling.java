package org.whitehotstone.security.wsdl.crawler.model.configuration.sources.handling;

import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class WsdlSourceHandling {

    @SerializedName("merge-strategies")
    @Expose
    private List<MergeServiceStrategy> mergeStrategies;

    public List<MergeServiceStrategy> getMergeStrategies() {
        return mergeStrategies;
    }
    public void setMergeStrategies(List<MergeServiceStrategy> mergeStrategies) {
        this.mergeStrategies = mergeStrategies;
    }
    public WsdlSourceHandling withMergeStrategies(List<MergeServiceStrategy> mergeStrategies) {
        this.mergeStrategies = mergeStrategies;
        return this;
    }

}
