//
//  LWWElementSet.swift
//  
//
//  Created by Saúl Moreno Abril on 30/3/21.
//

import Foundation

/// A LWW-Element-set implementation which attaches a timestamp to each element added or removed.
/// It is created by two sets, add and remove sets.
///
/// References:
/// <https://github.com/pfrazee/crdt_notes>
///
public struct LWWElementSet<T: Hashable> {
    @usableFromInline internal var addSet = TimeGSet<T>()
    @usableFromInline internal var removeSet = TimeGSet<T>()

    /// Returns the effective elements, namely, the added but not removed elements.
    @inlinable public var elements: Set<T> {
        addSet.elements.filter { lookup($0) != nil }
    }
    
    /// Returns the last date when the element was added to this set, or nil if the element was removed or never added.
    /// - Parameter element: The element to search.
    /// - Returns: A Date value indicating whether the element was added or nil.
    @inlinable public func lookup(_ element: T) -> Date? {
        guard let addDate = addSet.lookup(element) else { return nil }
        
        guard let removeDate = removeSet.lookup(element) else { return addDate }
        
        return addDate > removeDate ? addDate : nil
    }
    
    /// Checks if the current set is a subset of another one.
    /// - Parameter set: The other set.
    /// - Returns: A Boolean value indicating whether the instance is a subset.
    @inlinable public func isSubset(of set: LWWElementSet<T>) -> Bool {
        addSet.isSubset(of: set.addSet) && removeSet.isSubset(of: set.removeSet)
    }
    
    /// Adds an element to this set.
    /// - Parameter element: The element to add.
    /// - Parameter date: The date when `element` was added into this set. By default the current system date is used.
    @inlinable public mutating func add(_ element: T, date: Date = Date()) {
        addSet.add(element, date: date)
    }
    
    /// Removes an element from this set if it was added, i.e., simply was added or was added after being removed.
    /// - Parameters:
    /// - Parameter element: The element to remove.
    /// - Parameter date: The date when `element` was removed from this set. By default the current system date is used.
    @inlinable public mutating func remove(_ element: T, date: Date = Date()) {
        guard lookup(element) != nil else { return }
        removeSet.add(element, date: date)
    }
    
    /// Merges another set into this set.
    /// - Parameter set: The set to merge into this set.
    @inlinable public mutating func merge(_ set: LWWElementSet<T>) {
        addSet.merge(set.addSet)
        removeSet.merge(set.removeSet)
    }
    
}
