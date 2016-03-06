package org.whitehotstone.security.wsdl.crawler.model.graph

import static extension com.google.common.base.Preconditions.checkState
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkArgument

class Vertex<O> {
    Integer index = null

    O object

    new(O object) {
        object.checkNotNull
        this.object = object
    }

    def void setIndex(Integer index) {
        (this.index == null).checkState
        index.checkNotNull()
        (index >= 0).checkArgument('''The given index '«index»' is negative.''')
        this.index = index
    }

    def Integer getIndex() {
        this.index
    }

    def getObject() {
        object
    }

    def isInitialized() {
        index != null
    }

    override public int hashCode() {
        return index
    }

    override public boolean equals(Object other) {
        other instanceof Vertex && ((other as Vertex).index == this.index && (other as Vertex).object == this.object)
    }

    def boolean similar(Object other) {
        other instanceof Vertex && ((other as Vertex).object == this.object)
    }
}
