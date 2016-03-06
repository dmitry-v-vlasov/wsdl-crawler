package org.whitehotstone.security.wsdl.crawler.model.configuration.sources;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Generated("org.whitehotstone.security.wsdl")
public class ServiceDefinition {

    @SerializedName("id")
    @Expose
    private String id;

    @SerializedName("namespace")
    @Expose
    private String namespace;

    @SerializedName("service-name")
    @Expose
    private String serviceName;

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public ServiceDefinition withId(String id) {
        this.id = id;
        return this;
    }

    public String getNamespace() {
        return namespace;
    }
    public void setNamespace(String namespace) {
        this.namespace = namespace;
    }
    public ServiceDefinition withNamespace(String namespace) {
        this.namespace = namespace;
        return this;
    }

    public String getServiceName() {
        return serviceName;
    }
    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }
    public ServiceDefinition withServiceName(String serviceName) {
        this.serviceName = serviceName;
        return this;
    }
}
