package org.whitehotstone.security.wsdl.crawler.model.graph

import java.util.ArrayDeque
import java.util.Deque

import static extension com.google.common.base.Preconditions.checkArgument
import static extension com.google.common.base.Preconditions.checkNotNull
import static extension com.google.common.collect.Lists.newArrayList
import static extension java.util.Arrays.fill
import java.util.List

final class DFSDigraphTraversal {
    private new() {
        //empty
    }

    def static <O extends Object> void traverse(DirectedGraph<O, Vertex<O>> graph, Vertex<O> startingVertex, Visitor<O, Vertex<O>> visitor, List<Vertex<O>> top) {
        graph.checkNotNull()
        startingVertex.checkNotNull()
        graph.vertexExists(startingVertex).checkArgument()
        visitor.checkNotNull()

        (!graph.empty).checkArgument

        val boolean[] discovered = newBooleanArrayOfSize(graph.size)
        val boolean[] processed = newBooleanArrayOfSize(graph.size)
        discovered.fill(false)
        processed.fill(false)

        val Deque<Vertex<O>> stack = new ArrayDeque(32)
        stack.push(startingVertex)
        while(!stack.empty) {
            val head = stack.peek
            if(!discovered.get(head.index)) {
                discovered.set(head.index, true)
                visitor.processVertexEarly(head)
            }

            val targetVertices = graph.connectedVertices(head)
            if(targetVertices.nullOrEmpty) {
                val stackCopy = stack.newArrayList
                if (!top.nullOrEmpty) {
                    top.reverseView.forEach[stackCopy.add(it)]
                }
                val discoveredPath = stackCopy.reverseView
                visitor.processAsLeaf(head, discoveredPath)
                // We do not check "processed" because we can have alternative paths to the same primitive field we mask/hide.
                processed.set(head.index, true)
                stack.pop
            }
            else {
                val nextVertex = targetVertices.findFirst[!discovered.get(index)]
                if(nextVertex == null) {
                    visitor.processVertexLate(head)

                    processed.set(head.index, true)

                    for (child : targetVertices) {
                        discovered.set(child.index, false)
                    }

                    stack.pop
                }
                else {
                    if (stack.contains(nextVertex)) {
                        // A cycle is detected
                        while(stack.peek != nextVertex) {
                            stack.pop
                        }
                        stack.pop
                    }
                    visitor.processEdge(head, nextVertex)
                    stack.push(nextVertex)
                }
            }
        }
    }        
}
