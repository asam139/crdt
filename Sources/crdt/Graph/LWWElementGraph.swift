//
//  LWWElementGraph.swift
//  
//
//  Created by Saul Moreno Abril on 31/3/21.
//

import Foundation

public struct LWWElementGraph<T: Hashable> {
    public typealias LWWEdge = Edge<T>

    @usableFromInline internal var verticesSet = LWWElementSet<T>()
    @usableFromInline internal var edgesSet = LWWElementSet<LWWEdge>()

    /// Returns the effective vertices, namely, the added but not removed elements.
    @inlinable public var vertices: Set<T> { verticesSet.elements }

    /// Returns the effective edges, namely, the added but not removed elements.
    @inlinable public var edges: Set<LWWEdge> { edgesSet.elements }
}
