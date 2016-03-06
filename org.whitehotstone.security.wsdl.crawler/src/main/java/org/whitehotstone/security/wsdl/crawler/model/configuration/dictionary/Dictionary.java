package org.whitehotstone.security.wsdl.crawler.model.configuration.dictionary;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Generated;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.google.common.base.Splitter;

import static com.google.common.collect.Lists.newArrayList;

@Generated("org.whitehotstone.security.wsdl")
public class Dictionary {

    private static final Splitter HSPLIT = Splitter.on('/');

    @SerializedName("masked")
    @Expose
    private List<Masked> masked = new ArrayList<>();

    @SerializedName("hidden")
    @Expose
    private List<String> hidden = new ArrayList<>();

    private List<List<String>> hiddenParts = new ArrayList<>();

    @SerializedName("keep-extra-top")
    @Expose
    private int keepExtraTop;
    
    @SerializedName("swallow-partial-patterns")
    @Expose
    private boolean swallowPartialPatterns;
    
    public List<Masked> getMasked() {
        return masked;
    }
    public void setMasked(List<Masked> masked) {
        this.masked = masked;
    }
    public Dictionary withMasked(List<Masked> masked) {
        this.masked = masked;
        return this;
    }

    public List<String> getHidden() {
        return hidden;
    }
    public void setHidden(List<String> hidden) {
        this.hidden = hidden;
        for (String hpattern : this.hidden) {
            this.hiddenParts.add(newArrayList(HSPLIT.split(hpattern)));
        }
    }
    public Dictionary withHidden(List<String> hidden) {
        this.hidden = hidden;
        return this;
    }
    public List<List<String>> getHiddenParts() {
        if (hiddenParts.isEmpty()) {
            for (String hpattern : this.hidden) {
                if(hpattern != null) {
                    this.hiddenParts.add(newArrayList(HSPLIT.split(hpattern)));
                }
            }
        }
        return hiddenParts;
    }

    public int getKeepExtraTop() {
        return keepExtraTop;
    }
    public void setKeepExtraTop(int keepExtraTop) {
        this.keepExtraTop = keepExtraTop;
    }
    public Dictionary withKeepExtraTop(int keepExtraTop) {
        this.keepExtraTop = keepExtraTop;
        return this;
    }

    public boolean getSwallowPartialPatterns() {
        return swallowPartialPatterns;
    }
    public void setSwallowPartialPatterns(boolean swallowPartialPatterns) {
        this.swallowPartialPatterns = swallowPartialPatterns;
    }
    public Dictionary withSwallowPartialPatterns(boolean swallowPartialPatterns) {
        this.swallowPartialPatterns = swallowPartialPatterns;
        return this;
    }
}
