package org.whitehotstone.security.wsdl.crawler.model.configuration.dictionary;

import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.google.common.base.Splitter;

import static com.google.common.collect.Lists.newArrayList;

@Generated("org.whitehotstone.security.wsdl")
public class Masked {

    private static final Splitter MSPLIT = Splitter.on('/');

    @SerializedName("value")
    @Expose
    private String value;

    private List<String> parts;

    @SerializedName("constraints")
    @Expose
    private Constraints constraints;

    public String getValue() {
        return value;
    }
    public void setValue(String value) {
        this.value = value;
        this.parts = newArrayList(MSPLIT.split(this.value));
    }
    public Masked withValue(String value) {
        this.value = value;
        return this;
    }

    public List<String> getParts() {
        if (parts == null) {
            this.parts = newArrayList(MSPLIT.split(this.value));
        }
        return parts;
    }

    public Constraints getConstraints() {
        return constraints;
    }
    public void setConstraints(Constraints constraints) {
        this.constraints = constraints;
    }
    public Masked withConstraints(Constraints constraints) {
        this.constraints = constraints;
        return this;
    }
}
