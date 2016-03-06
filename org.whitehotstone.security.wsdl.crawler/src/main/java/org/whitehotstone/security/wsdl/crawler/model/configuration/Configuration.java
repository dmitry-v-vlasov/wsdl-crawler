package org.whitehotstone.security.wsdl.crawler.model.configuration;

import javax.annotation.Generated;

import org.whitehotstone.security.wsdl.crawler.model.configuration.dictionary.Dictionary;
import org.whitehotstone.security.wsdl.crawler.model.configuration.generator.Generator;
import org.whitehotstone.security.wsdl.crawler.model.configuration.sources.Sources;
import org.whitehotstone.security.wsdl.crawler.model.configuration.sources.handling.SourceHandling;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;


@Generated("org.whitehotstone.security.wsdl")
public class Configuration {

    @SerializedName("dictionary")
    @Expose
    private Dictionary dictionary;

    @SerializedName("sources")
    @Expose
    private Sources sources;

    @SerializedName("source-handling")
    @Expose
    private SourceHandling sourceHandling;

    @SerializedName("generator")
    @Expose
    private Generator generator;

    public Dictionary getDictionary() {
        return dictionary;
    }
    public void setDictionary(Dictionary dictionary) {
        this.dictionary = dictionary;
    }
    public Configuration withDictionary(Dictionary dictionary) {
        this.dictionary = dictionary;
        return this;
    }

    public Sources getSources() {
        return sources;
    }
    public void setSources(Sources sources) {
        this.sources = sources;
    }
    public Configuration withSources(Sources sources) {
        this.sources = sources;
        return this;
    }

    public SourceHandling getSourceHandling() {
        return sourceHandling;
    }
    public void setSourceHandling(SourceHandling sourceHandling) {
        this.sourceHandling = sourceHandling;
    }
    public Configuration withSourceHandling(SourceHandling sourceHandling) {
        this.sourceHandling = sourceHandling;
        return this;
    }

    public Generator getGenerator() {
        return generator;
    }
    public void setGenerator(Generator generator) {
        this.generator = generator;
    }
    public Configuration withGenerator(Generator generator) {
        this.generator = generator;
        return this;
    }

}
