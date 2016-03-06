package org.whitehotstone.security.wsdl.crawler.model.configuration.dictionary;

import javax.annotation.Generated;
import com.google.gson.annotations.Expose;


@Generated("org.whitehotstone.security.wsdl")
public class Constraints {

    @Expose
    private int left = -1;
    @Expose
    private int right = -1;

    public int getLeft() {
        return left;
    }
    public void setLeft(int left) {
        this.left = left;
    }
    public Constraints withLeft(int left) {
        this.left = left;
        return this;
    }

    public int getRight() {
        return right;
    }
    public void setRight(int right) {
        this.right = right;
    }
    public Constraints withRight(int right) {
        this.right = right;
        return this;
    }
}
