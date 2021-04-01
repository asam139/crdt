//
//  LWWElementGraph.swift
//  
//
//  Created by Saul Moreno Abril on 31/3/21.
//

import Foundation

/// LWWElementGraph
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


    @inlinable mutating func addVertex(_ element: T, date: Date = Date()) {
        verticesSet.add(element, date: date)
    }

    @discardableResult
    @inlinable mutating func removeVertex(_ element: T, date: Date = Date()) -> Bool {
        let wasRemoved = verticesSet.remove(element, date: date)
        if wasRemoved { // Remove invalid edges
            edgesSet.elements.filter { $0.contains(element) }.forEach {
                edgesSet.remove($0, date: date)
            }
        }
        return wasRemoved
    }

    @discardableResult
    @inlinable mutating func addEdge(_ edge: LWWEdge, date: Date = Date()) -> Bool {
        guard verticesSet.lookup(edge.from) != nil && verticesSet.lookup(edge.to) != nil else { return false }

        edgesSet.add(edge, date: date)
        return true
    }

    @discardableResult
    @inlinable mutating func addEdge(from: T, to: T, date: Date = Date()) -> Bool {
        let edge = LWWEdge(from: from, to: to)
        return addEdge(edge, date: date)
    }

    @discardableResult
    @inlinable mutating func removeEdge(_ edge: LWWEdge, date: Date = Date()) -> Bool {
        let wasRemoved = edgesSet.remove(edge, date: date)
        if wasRemoved { // Remove `from` or `to` if they have no other edges
            let (from, to) = (edge.from, edge.to)
            let elements = edgesSet.elements

            if elements.contains(where: { $0.contains(from) }) { // `from` has other edges
                verticesSet.remove(from, date: date)
            }

            if elements.contains(where: { $0.contains(to) }) { // `to` has other edges
                verticesSet.remove(to, date: date)
            }
        }
        return wasRemoved
    }

    @inlinable func existsVertex(_ element: T) -> Bool { verticesSet.exists(element) }

    @inlinable func verticesConnectedTo(_ element: T) -> [T] {
        edgesSet.elements.compactMap { edge in
            if edge.to == element {
                return edge.from
            } else if edge.from == element {
                return edge.to
            }
            return nil
        }
    }

    @inlinable func path(from: T, to: T) -> [T] {

    }
}

// MARK: - Private Methods
internal extension LWWElementGraph {

}
