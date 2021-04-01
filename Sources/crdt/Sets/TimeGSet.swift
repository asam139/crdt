//
//  TimeGSet.swift
//  
//
//  Created by Saúl Moreno Abril on 30/3/21.
//

import Foundation

/// An unordered collection of unique elements by date when were added.
/// It is a variant of the standart Grow-only set but implemented using a dictionary to add the elements by the date easily.
///
/// References:
/// <https://github.com/pfrazee/crdt_notes>
///
public struct TimeGSet<T: Hashable> {
    /// A dictionary that stores the time an element was added.
    @usableFromInline internal var dates = [T: Date]()

    /// Returns the added elements.
    @inlinable public var elements: Set<T> {
        Set(dates.keys)
    }
    
    /// Returns the date when `element` was added to this set, if it was added.
    /// - Parameter element: The element to search.
    /// - Returns: A Date value indicating whether the element was added or nil.
    @inlinable public func lookup(_ element: T) -> Date? { dates[element] }

    /// Returns a Boolean value indicating whether `element` was added to this set.
    /// - Parameter element: The element to search.
    /// - Returns: A Boolean value indicating whether the element was added.
    @inlinable public func exists(_ element: T) -> Bool { lookup(element) != nil }
    
    /// Checks if the current set is a subset of another one.
    /// - Parameter set: The other set.
    /// - Returns: A Boolean value indicating whether the instance is a subset.
    @inlinable public func isSubset(of set: Self<T>) -> Bool {
        dates.allSatisfy { set.lookup($0.key) != nil }
    }
    
    /// Adds an element to this set.
    /// - Parameter element: The element to add.
    /// - Parameter date: The date when `element` was added into this set. By default the current system date is used.
    @inlinable public mutating func add(_ element: T, date: Date = Date()) {
        if let previousDate = lookup(element), previousDate >= date {
            return
        }
        dates[element] = date
    }
    
    /// Merges another set into this set, selecting the later timestamp if there are multiple for the same element.
    ///
    /// - Parameter anotherSet: The set to merge into this set.
    @inlinable public mutating func merge(_ set: Self<T>) {
        dates.merge(set.dates) { (current, new) in max(current, new) }
    }
}
