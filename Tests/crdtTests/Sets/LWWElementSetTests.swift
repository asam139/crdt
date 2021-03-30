//
//  LWWElementSetTests.swift
//  
//
//  Created by Saúl Moreno Abril on 30/3/21.
//
import XCTest
@testable import crdt

final class LWWElementSetTests: XCTestCase {
    var sut: LWWElementSet<Int>!
    
    let firstPairOlder: TestPair = (Date(timeIntervalSinceNow: -10), 1)
    let firstPair: TestPair = (Date(), 1)
    let firstPairNewer: TestPair = (Date(timeIntervalSinceNow: 10), 1)
    let secondPairOlder: TestPair = (Date(timeIntervalSinceNow: -15), 2)
    let secondPair: TestPair = (Date(timeIntervalSinceNow: 5), 2)
    let thirdPair: TestPair = (Date(timeIntervalSinceNow: 10), 3)
    
    override func setUp() {
        super.setUp()
        sut = .init()
    }
    
    func testAddElements() {
        sut.add(firstPair.element, date: firstPair.date)
        XCTAssertEqual(sut.addSet.dates.first?.value, firstPair.date, "Expect element is added the first time")
        
        sut.add(firstPairOlder.element, date: firstPairOlder.date)
        XCTAssertEqual(sut.addSet.dates.first?.value, firstPair.date, "Expect element not to be updated if the date is older")
        
        sut.add(firstPairNewer.element, date: firstPairNewer.date)
        XCTAssertEqual(sut.addSet.dates.first?.value, firstPairNewer.date, "Expect element to be updated if the date is newer")
    }
    
    func testRemoveElements() {
        sut.remove(firstPair.element, date: firstPair.date)
        XCTAssertTrue(sut.removeSet.dates.isEmpty, "Expect element not to be removed if the item is not already in the set")
        
        sut.add(firstPair.element, date: firstPair.date)
        sut.remove(firstPair.element, date: firstPair.date)
        XCTAssertEqual(sut.removeSet.dates.first?.value, firstPair.date, "Expect element to be removed if the element was not removed before.")
        
        sut.remove(firstPairOlder.element, date: firstPairOlder.date)
        XCTAssertEqual(sut.removeSet.dates.first?.value, firstPair.date, "Expect element to be removed if the element was not removed previously")
        
        sut.remove(firstPairNewer.element, date: firstPairNewer.date)
        XCTAssertEqual(sut.removeSet.dates.first?.value, firstPair.date, "Expect element not to be updated if the element was not added in newer date")
        
        sut.add(firstPairNewer.element, date: firstPairNewer.date)
        sut.remove(firstPairNewer.element, date: firstPairNewer.date)
        XCTAssertEqual(sut.removeSet.dates.first?.value, firstPairNewer.date, "Expect element to be updated if the element was added in newer date")
    }
    
    func testLookupElements() {
        XCTAssertNil(sut.lookup(firstPair.element), "Expect to return nil if the element was never added.")
        
        sut.add(firstPair.element, date: firstPair.date)
        XCTAssertEqual(sut.lookup(firstPair.element), firstPair.date, "Expect to return the date if the element was added.")
        
        sut.remove(firstPairOlder.element, date: firstPairOlder.date)
        XCTAssertEqual(sut.lookup(firstPair.element), firstPair.date, "Expect to return the date if the element was added previously to be removed.")
        
        sut.remove(firstPairNewer.element, date: firstPairNewer.date)
        XCTAssertNil(sut.lookup(firstPair.element), "Expect to return nil if the element was removed previouslyto be added.")
    }

    func testIsSubset() {
        var secondSet = LWWElementSet<Int>()
        XCTAssertTrue(sut.isSubset(of: secondSet), "Expect empty sets to be subsets")
        
        sut.add(firstPair.element, date: firstPair.date)
        XCTAssertTrue(sut.isSubset(of: sut), "Expect to be subset itself")
        
        secondSet.add(firstPairNewer.element, date: firstPairNewer.date)
        secondSet.add(secondPair.element, date: secondPair.date)
        secondSet.add(thirdPair.element, date: thirdPair.date)

        XCTAssertTrue(sut.isSubset(of: secondSet), "Expect first set to be a subset of the second set")
        XCTAssertFalse(secondSet.isSubset(of: sut), "Expect second set not to be a subset of the first set")
    }

    func testMerge() {
        sut.add(firstPair.element, date: firstPair.date)
        sut.add(secondPair.element, date: secondPair.date)
        
        var secondSet = LWWElementSet<Int>()
        secondSet.add(firstPair.element, date: firstPair.date)
        secondSet.remove(firstPairNewer.element, date: firstPairNewer.date)
        secondSet.add(secondPairOlder.element, date: secondPairOlder.date)
        secondSet.add(thirdPair.element, date: thirdPair.date)

        sut.merge(secondSet)

        XCTAssertNil(sut.lookup(firstPairNewer.element), "Expect first element to be removed because was the step was done after.")
        XCTAssertEqual(sut.lookup(secondPair.element), secondPair.date, "Expect second element exists because was added before in the set.")
        XCTAssertEqual(sut.lookup(thirdPair.element), thirdPair.date, "Expect third element exists because was only added in the second set.")
    }
}

