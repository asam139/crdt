//
//  Edge.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import Foundation

/// Representation of a edge of a graph with a initial and end vertices.
public struct Edge<T: Hashable>: Hashable {
    public let from: T
    public let to: T

    public init(from: T, to: T) {
        self.from = from
        self.to = to
    }

    
    /// Check if the edge includes an vertex.
    /// - Parameter element: The vertex to check.
    /// - Returns: A Boolean indicating if the vertex is the start or end of the edge.
    @inlinable public func contains(_ element: T) -> Bool {
        to == element || from == element
    }
}
