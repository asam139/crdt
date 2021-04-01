//
//  Stack.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import Foundation

public struct Stack<T> {
    @usableFromInline internal var array: [T] = []

    public init() {}

    @inlinable public mutating func push(_ element: T) {
        array.append(element)
    }

    @inlinable public mutating func pop() -> T? { array.popLast() }

    @inlinable public func peek() -> T? { array.last }
}
