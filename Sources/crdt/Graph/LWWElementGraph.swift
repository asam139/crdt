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

    @usableFromInline internal var verticesSet = LWWElementSet<T>()
    @usableFromInline internal var edgesSet = LWWElementSet<LWWEdge>()

    /// Returns the effective vertices, namely, the added but not removed elements.
    @inlinable public var vertices: Set<T> { verticesSet.elements }

    /// Returns the effective edges, namely, the added but not removed elements.
    @inlinable public var edges: Set<LWWEdge> { edgesSet.elements }

    @inlinable public mutating func addVertice(_ element: T, date: Date = Date()) {
        verticesSet.add(element, date: date)
    }

    @discardableResult
    @inlinable public mutating func removeVertice(_ element: T, date: Date = Date()) -> Bool {
        let wasRemoved = verticesSet.remove(element, date: date)
        if wasRemoved { // Remove invalid edges
            edgesSet.elements.filter { $0.contains(element) }.forEach {
                edgesSet.remove($0, date: date)
            }
        }
        return wasRemoved
    }
}
