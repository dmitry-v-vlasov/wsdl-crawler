package org.whitehotstone.security.wsdl.crawler.model.configuration.generator;

import javax.annotation.Generated;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;


/**
 * ConfigurationNames
 * <p>
 * 
 * 
 */
@Generated("org.whitehotstone.security.wsdl")
public class ConfigNames {

    /**
     * patternMaskedIncoming
     * <p>
     * 
     * 
     */
    @SerializedName("pattern-masked-incoming")
    @Expose
    private String patternMaskedIncoming;
    /**
     * patternMaskedOutcoming
     * <p>
     * 
     * 
     */
    @SerializedName("pattern-masked-outcoming")
    @Expose
    private String patternMaskedOutcoming;
    /**
     * patternHiddenIncoming
     * <p>
     * 
     * 
     */
    @SerializedName("pattern-hidden-incoming")
    @Expose
    private String patternHiddenIncoming;
    /**
     * patternHiddenOutcoming
     * <p>
     * 
     * 
     */
    @SerializedName("pattern-hidden-outcoming")
    @Expose
    private String patternHiddenOutcoming;

    /**
     * patternMaskedIncoming
     * <p>
     * 
     * 
     * @return
     *     The patternMaskedIncoming
     */
    public String getPatternMaskedIncoming() {
        return patternMaskedIncoming;
    }

    /**
     * patternMaskedIncoming
     * <p>
     * 
     * 
     * @param patternMaskedIncoming
     *     The pattern-masked-incoming
     */
    public void setPatternMaskedIncoming(String patternMaskedIncoming) {
        this.patternMaskedIncoming = patternMaskedIncoming;
    }

    public ConfigNames withPatternMaskedIncoming(String patternMaskedIncoming) {
        this.patternMaskedIncoming = patternMaskedIncoming;
        return this;
    }

    /**
     * patternMaskedOutcoming
     * <p>
     * 
     * 
     * @return
     *     The patternMaskedOutcoming
     */
    public String getPatternMaskedOutcoming() {
        return patternMaskedOutcoming;
    }

    /**
     * patternMaskedOutcoming
     * <p>
     * 
     * 
     * @param patternMaskedOutcoming
     *     The pattern-masked-outcoming
     */
    public void setPatternMaskedOutcoming(String patternMaskedOutcoming) {
        this.patternMaskedOutcoming = patternMaskedOutcoming;
    }

    public ConfigNames withPatternMaskedOutcoming(String patternMaskedOutcoming) {
        this.patternMaskedOutcoming = patternMaskedOutcoming;
        return this;
    }

    /**
     * patternHiddenIncoming
     * <p>
     * 
     * 
     * @return
     *     The patternHiddenIncoming
     */
    public String getPatternHiddenIncoming() {
        return patternHiddenIncoming;
    }

    /**
     * patternHiddenIncoming
     * <p>
     * 
     * 
     * @param patternHiddenIncoming
     *     The pattern-hidden-incoming
     */
    public void setPatternHiddenIncoming(String patternHiddenIncoming) {
        this.patternHiddenIncoming = patternHiddenIncoming;
    }

    public ConfigNames withPatternHiddenIncoming(String patternHiddenIncoming) {
        this.patternHiddenIncoming = patternHiddenIncoming;
        return this;
    }

    /**
     * patternHiddenOutcoming
     * <p>
     * 
     * 
     * @return
     *     The patternHiddenOutcoming
     */
    public String getPatternHiddenOutcoming() {
        return patternHiddenOutcoming;
    }

    /**
     * patternHiddenOutcoming
     * <p>
     * 
     * 
     * @param patternHiddenOutcoming
     *     The pattern-hidden-outcoming
     */
    public void setPatternHiddenOutcoming(String patternHiddenOutcoming) {
        this.patternHiddenOutcoming = patternHiddenOutcoming;
    }

    public ConfigNames withPatternHiddenOutcoming(String patternHiddenOutcoming) {
        this.patternHiddenOutcoming = patternHiddenOutcoming;
        return this;
    }

}
