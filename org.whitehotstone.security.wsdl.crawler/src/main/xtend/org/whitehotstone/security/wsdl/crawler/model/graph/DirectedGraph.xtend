package org.whitehotstone.security.wsdl.crawler.model.graph

import java.util.ArrayList
import org.apache.commons.collections4.list.TreeList

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.base.Preconditions.checkState

/**
 * We could introduce a graph interface/class hierarchy but does not make sense for the concrete task.
 */
class DirectedGraph<O extends Object, V extends Vertex<O>> {
    var indexCounter = -1
    val adjacency = new ArrayList<ArrayList<V>>
    val vertices = new ArrayList<V>
    val rootVertices = new ArrayList<V>

    def addVertex(V vertex) {
        vertex.checkNotNull()
        (!vertex.initialized).checkArgument
        vertex.object.checkNotNull

        vertex.index = indexCounter += 1

        // vertex.index is made equal to its position in the vertices&adjacency list
        vertices.add(vertex); val verticesList = new ArrayList<V>; adjacency.add(verticesList)
        vertex.initialized.checkState()
        ((vertex.index == vertices.size - 1) && (vertex.index == adjacency.size - 1)).checkState()
        (vertices.get(vertex.index) == vertex).checkState()
        return vertex
    }

    def addRootVertex(V vertex) {
        val resultingVertex = vertex.addVertex
        rootVertices.add(vertex)
        return resultingVertex
    }

    def addEdge(V source, V target) {
        source.checkNotNull(); target.checkNotNull()
        source.initialized.checkArgument()
        (source.index < vertices.size).checkArgument()
        (vertices.get(source.index) == source).checkArgument()

        val resultTarget = if (target.initialized) {
            (target.index < vertices.size).checkArgument()
            (vertices.get(target.index) == target).checkArgument()
            target
        }
        else {
            target.addVertex
        }
        val verticesList = adjacency.get(source.index)
        if(!verticesList.contains(resultTarget)) {
            verticesList.add(resultTarget)
        }
    }

    def getRootVertices() {
        rootVertices.unmodifiableView
    }

    def connectedVertices(V vertex) {
        vertex.checkNotNull()
        vertex.initialized.checkArgument()
        (vertex.index < vertices.size).checkArgument()
        (vertices.get(vertex.index) == vertex).checkArgument()
        adjacency.get(vertex.index).unmodifiableView
    }

    def vertexExists(V vertex) {
        vertex != null && vertex.initialized && vertex.index < vertices.size && vertices.get(vertex.index) == vertex
    }

    def findSimilarVertex(V vertex) {
        if (vertex == null) {
            return null
        }
        vertices.findFirst[similar(vertex)]
    }

    def size() {
        (vertices.size == adjacency.size).checkState()
        vertices.size
    }

    def isEmpty() {
        (vertices.size == adjacency.size).checkState()
        vertices.empty
    }
}
