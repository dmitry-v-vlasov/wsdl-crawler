package org.whitehotstone.security.wsdl.crawler.model.configuration.sources.handling;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class SourceHandling {

    @SerializedName("artifact-ids")
    @Expose
    private List<List<String>> artifactIds = new ArrayList<>();

    @SerializedName("wsdl")
    @Expose
    private WsdlSourceHandling wsdl;

    public List<List<String>> getArtifactIds() {
        return artifactIds;
    }
    public void setArtifactIds(List<List<String>> artifactIds) {
        this.artifactIds = artifactIds;
    }
    public SourceHandling withArtifactIds(List<List<String>> artifactIds) {
        this.artifactIds = artifactIds;
        return this;
    }

    public WsdlSourceHandling getWsdl() {
        return wsdl;
    }
    public void setWsdl(WsdlSourceHandling wsdl) {
        this.wsdl = wsdl;
    }
    public SourceHandling withWsdl(WsdlSourceHandling wsdl) {
        this.wsdl = wsdl;
        return this;
    }
}
