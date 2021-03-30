//
//  TimeGSetTests.swift
//
//
//  Created by Saúl Moreno Abril on 30/3/21.
//

import XCTest
@testable import crdt

final class TimeGSetTests: XCTestCase {
    var sut: TimeGSet<Int>!
    let firstPair: TestPair = (Date(), 1)
    let firstPairNewer: TestPair = (Date(timeIntervalSinceNow: 10), 1)
    let secondPair: TestPair = (Date(timeIntervalSinceNow: 5), 2)
    let secondPairOlder: TestPair = (Date(timeIntervalSinceNow: -15), 2)
    let thirdPair: TestPair = (Date(timeIntervalSinceNow: 15), 3)
    
    override func setUp() {
        super.setUp()
        sut = .init()
    }
    
    func testAddElements() {
        var count = 0
        
        sut.add(firstPair.element, date: firstPair.date)
        let first = sut.dates.first
        XCTAssertTrue(
            first?.key == firstPair.element && first?.value == firstPair.date,
            "Expect element is added the first time."
        )
        
        sut.add(firstPair.element, date: firstPair.date)
        count += 1
        XCTAssertEqual(sut.dates.count, count, "Expect element not to be added if date is older or the same.")
            
        sut.add(secondPair.element, date: secondPair.date)
        count += 1
        XCTAssertEqual(sut.dates.count, count, "Expect element to be added if it is newer.")
        
        sut.add(firstPairNewer.element, date: firstPairNewer.date)
        XCTAssertEqual(sut.dates.count, count, "Expect element to be updated if the date is newer.")
        XCTAssertEqual(sut.dates[firstPairNewer.element], firstPairNewer.date)
    }
    
    func testLookupElements() {
        sut.add(firstPair.element, date: firstPair.date)
        
        XCTAssertNotNil(sut.lookup(firstPair.element), "Expect to return the date is element is added")
        XCTAssertNil(sut.lookup(secondPair.element), "Expect date not to be returned if element was not added.")
    }
    
    func testIsSubset() {
        var secondSet = TimeGSet<Int>()
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
        var secondSet = TimeGSet<Int>()
        secondSet.add(firstPairNewer.element, date: firstPairNewer.date)
        secondSet.add(secondPairOlder.element, date: secondPairOlder.date)
        secondSet.add(thirdPair.element, date: thirdPair.date)
        
        sut.merge(secondSet)
    
        XCTAssertEqual(sut.lookup(firstPairNewer.element), firstPairNewer.date)
        XCTAssertEqual(sut.lookup(secondPair.element), secondPair.date)
        XCTAssertEqual(sut.lookup(thirdPair.element), thirdPair.date)
    }
}
