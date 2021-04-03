//
//  Stack.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import Foundation

/// Data structure that allows to keep the  Last in First Out order.
public struct Stack<T> {
    @usableFromInline internal var array: [T] = []

    public init() {}
    
    /// Push is used to insert an element to a stack.
    /// - Parameter element: The element to be added.
    @inlinable public mutating func push(_ element: T) {
        array.append(element)
    }
    
    /// Pop is used to remove the topmost element.
    /// - Returns: The last element that was removed if it is not empty.
    @inlinable public mutating func pop() -> T? { array.popLast() }
    
    /// Peek is used to view the topmost element.
    /// - Returns: The last element in the stack.
    @inlinable public func peek() -> T? { array.last }
}
