//
//  LWWElementGraph.swift
//  
//
//  Created by Saul Moreno Abril on 31/3/21.
//

import Foundation

/// Last-Writer-Wins-Element graph represents pairwise relationships between objects, nodes/vertices and edges.
/// The graph keeps each update with a timestamp to know the most recent update.
/// The vertices and edges are represented using two set of kind LWW which are prepared to keep the track of
/// adding and removing of each instance by timestamps.
///
/// References:
/// <https://github.com/pfrazee/crdt_notes>
///
public struct LWWElementGraph<T: Hashable> {
    /// Specific representation for a edge
    public typealias LWWEdge = Edge<T>

    /// Set to store vertices
    @usableFromInline internal var verticesSet = LWWElementSet<T>()

    /// Set to store edges
    @usableFromInline internal var edgesSet = LWWElementSet<LWWEdge>()
}

// MARK: - Public Methods
public extension LWWElementGraph {
    /// Returns the effective vertices, namely, the added but not removed elements.
    @inlinable var vertices: Set<T> { verticesSet.elements }

    /// Returns the effective edges, namely, the added but not removed elements.
    @inlinable var edges: Set<LWWEdge> { edgesSet.elements }

    /// Addes a vertex to this graph.
    /// - Parameters:
    ///   - element: The vertex to be added.
    ///   - date: The date when vertex was added into this set. By default the current system date is used.
    @inlinable mutating func addVertex(_ element: T, date: Date = Date()) {
        verticesSet.add(element, date: date)
    }

    /// Removes a vertex if it is added. Besides, it removes all invalid edges connected to the vertex.
    /// - Parameters:
    ///   - element: The vertex to be removed.
    ///   - date: The date when vertex was removed into this set. By default the current system date is used.
    /// - Returns: A Boolean value indicating if the vertex can be removed.
    @discardableResult @inlinable mutating func removeVertex(_ element: T, date: Date = Date()) -> Bool {
        let wasRemoved = verticesSet.remove(element, date: date)
        if wasRemoved { // Remove invalid edges
            edgesSet.elements.filter { $0.contains(element) }.forEach {
                edgesSet.remove($0, date: date)
            }
        }
        return wasRemoved
    }

    /// Adds an edge to the graph if it is possible, namely, both vertices have to exist.
    /// - Parameters:
    ///   - edge: The edge to be added.
    ///   - date: The date when edge was added into this set. By default the current system date is used.
    /// - Returns: A Boolean value indicating if the edge can be added.
    @discardableResult @inlinable mutating func addEdge(_ edge: LWWEdge, date: Date = Date()) -> Bool {
        guard existsVertex(edge.from) && existsVertex(edge.to) else { return false }
        edgesSet.add(edge, date: date)
        return true
    }

    /// Adds an edge using its both vertices to the graph if it is possible, namely, both vertices have to exist.
    /// - Parameters:
    ///   - from: The `from` vertex of the edge.
    ///   - to: The `to` vertex of the edge.
    ///   - date: The date when edge was added into this set. By default the current system date is used.
    /// - Returns: A Boolean value indicating if the edge can be added.
    @discardableResult @inlinable mutating func addEdge(from: T, to: T, date: Date = Date()) -> Bool {
        addEdge(LWWEdge(from: from, to: to), date: date)
    }

    /// Removes an edge from the graph removing the vertices if they have not more connections.
    /// - Parameters:
    ///   - edge: The edge to be removed
    ///   - date: The date when edge was removed into this set. By default the current system date is used.
    /// - Returns: A Boolean value indicating if the edge can be removed.
    @discardableResult @inlinable  mutating func removeEdge(_ edge: LWWEdge, date: Date = Date()) -> Bool {
        let wasRemoved = edgesSet.remove(edge, date: date)
        if wasRemoved { // Remove `from` or `to` if they have no other edges
            let (from, to) = (edge.from, edge.to)
            let elements = edgesSet.elements

            if !elements.contains(where: { $0.contains(from) }) { // `from` has other edges
                verticesSet.remove(from, date: date)
            }

            if !elements.contains(where: { $0.contains(to) }) { // `to` has other edges
                verticesSet.remove(to, date: date)
            }
        }
        return wasRemoved
    }

    /// Checks if it exists a vertex in the graph.
    /// - Parameter element: The vertex to check.
    /// - Returns: A Boolean value indicating whether the vertex exists.
    @inlinable func existsVertex(_ element: T) -> Bool {
        verticesSet.exists(element)
    }

    /// Finds all vertices connected to one vertex, namely, all the neighbours, it doesn't care if it is input or output.
    /// - Parameter from: The vertex from searching.
    /// - Returns: An array with all vertices.
    @inlinable func vertices(from element: T) -> [T] {
        edgesSet.elements.compactMap { edge in
            if edge.to == element {
                return edge.from
            } else if edge.from == element {
                return edge.to
            }
            return nil
        }
    }

    /// Finds all edges from a vertex, namely, all the neighbours.
    /// - Parameter from: The vertex from searching.
    /// - Returns: An array with all edges.
    @inlinable func edges(from: T) -> [LWWEdge] {
        edgesSet.elements.filter { $0.from == from }
    }

    /// Finds any path between two vertices if exists using Depth-First search (DFS) algorithm
    /// References:
    /// <https://en.wikipedia.org/wiki/Depth-first_search>
    /// - Parameters:
    ///   - from: The start vertex.
    ///   - to: The end vertex.
    /// - Returns: Returns an array with all vertices that defines the path.
    func path(from: T, to: T) -> [T]? {
        depthFirstSearch(from: from, to: to)?.array
    }

    /// Merges a graph to this graph
    /// - Parameter graph: The other graph.
    mutating func merge(_ graph: Self) {
        verticesSet.merge(graph.verticesSet)
        edgesSet.merge(graph.edgesSet)
    }
}

// MARK: - Private Methods
internal extension LWWElementGraph {
    /// Depth first search algorithm
    func depthFirstSearch(from: T, to: T) -> Stack<T>? {
        var visited = Set<T>()
        var stack = Stack<T>()

        stack.push(from)
        visited.insert(from)

        outer: while let vertex = stack.peek(), vertex != to {
            let neighbours = edges(from: vertex)
            guard neighbours.count > 0 else {
                _ = stack.pop() // backtrack
                continue
            }

            for edge in neighbours {
                if !visited.contains(edge.to) {
                    visited.insert(edge.to)
                    stack.push(edge.to)
                    continue outer
                }
            }

            _ = stack.pop() // backtrack
        }

        return stack.array.isEmpty ? nil : stack
    }
}
