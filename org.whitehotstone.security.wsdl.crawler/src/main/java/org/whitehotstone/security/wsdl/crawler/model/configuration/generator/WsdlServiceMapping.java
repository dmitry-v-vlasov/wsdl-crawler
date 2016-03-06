package org.whitehotstone.security.wsdl.crawler.model.configuration.generator;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class WsdlServiceMapping {

    @SerializedName("service-definition-id")
    @Expose
    private String serviceDefinitionId;

    @SerializedName("config-name-prefix")
    @Expose
    private String configNamePrefix;

    @SerializedName("artifact-id")
    @Expose
    private String artifactId;

    public String getServiceDefinitionId() {
        return serviceDefinitionId;
    }
    public void setServiceDefinitionId(String serviceDefinitionId) {
        this.serviceDefinitionId = serviceDefinitionId;
    }
    public WsdlServiceMapping withServiceDefinitionId(String serviceDefinitionId) {
        this.serviceDefinitionId = serviceDefinitionId;
        return this;
    }

    public String getConfigNamePrefix() {
        return configNamePrefix;
    }
    public void setConfigNamePrefix(String configNamePrefix) {
        this.configNamePrefix = configNamePrefix;
    }
    public WsdlServiceMapping withConfigNamePrefix(String configNamePrefix) {
        this.configNamePrefix = configNamePrefix;
        return this;
    }

    public String getArtifactId() {
        return artifactId;
    }
    public void setArtifactId(String artifactId) {
        this.artifactId = artifactId;
    }
    public WsdlServiceMapping withArtifactId(String artifactId) {
        this.artifactId = artifactId;
        return this;
    }
}
