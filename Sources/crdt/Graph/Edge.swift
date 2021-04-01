//
//  Edge.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import Foundation

public struct Edge<T: Hashable>: Hashable {
    public let from: T
    public let to: T

    public init(from: T, to: T) {
        self.from = from
        self.to = to
    }

    @inlinable public func contains(_ element: T) -> Bool {
        to == element || from == element
    }
}
