//
//  EdgeTests.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import XCTest
@testable import crdt

final class EdgeTests: XCTestCase {
    var sut: Edge<Int>!
    let from = 1
    let to = 3
    let other = 2


    override func setUp() {
        super.setUp()
        sut = Edge(from: from, to: to)
        sut2 = Edge(from: from, to: to)
    }

    func testInitWithFromAndTo() {
        let edge = Edge(from: from, to: to)
        XCTAssertEqual(edge.from, from)
        XCTAssertEqual(edge.to, to)
    }

    func testContains() {
        XCTAssertTrue(sut.contains(from))
        XCTAssertTrue(sut.contains(to))
        XCTAssertFalse(sut.contains(other))
    }
}
