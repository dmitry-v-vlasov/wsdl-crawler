package org.whitehotstone.security.wsdl.crawler.model.graph

import java.util.List

interface Visitor<O extends Object, V extends Vertex<O>> {
    def void processVertexEarly(V vertex)
    def void processEdge(V source, V target)
    def void processVertexLate(V vertex)
    def void processAsLeaf(V vertex, List<V> discoveredPath)
}
