//
//  LWWElementGraphTests.swift
//  
//
//  Created by Saul Moreno Abril on 1/4/21.
//

import XCTest
@testable import crdt

final class LWWElementGraphTests: XCTestCase {
    var sut: LWWElementGraph<Int>!

    let firstEdgePair: TestEdgePair = (Date(), .init(from: 1, to: 2))
    let secondEdgePair: TestEdgePair = (Date(timeIntervalSinceNow: 5), .init(from: 2, to: 3))
    let thirdEdgePair: TestEdgePair = (Date(timeIntervalSinceNow: 10), .init(from: 3, to: 2))

    override func setUp() {
        super.setUp()
        sut = LWWElementGraph()
    }

    func testAddVertex() {
        let date = firstEdgePair.date
        let firstVertex = firstEdgePair.edge.from
        let secondVertex = firstEdgePair.edge.to

        sut.addVertex(firstVertex, date: date)
        XCTAssertEqual(sut.vertices.count, 1, "Expect vertex to be added")

        sut.addVertex(secondVertex, date: date)
        XCTAssertEqual(sut.vertices.count, 2, "Expect vertex to be added")
    }

    func testRemoveVertex() {
        let date = firstEdgePair.date
        let edge = firstEdgePair.edge

        sut.addVertex(edge.from, date: date)
        XCTAssertTrue(sut.removeVertex(edge.from, date: date))
        XCTAssertEqual(sut.vertices.count, 0, "Expect vertex to be removed if vertex was added")

        let newerDate = date.addingTimeInterval(5)
        sut.addVertex(edge.from, date: newerDate)
        sut.addVertex(edge.to, date: newerDate)
        sut.addEdge(edge, date: newerDate)
        XCTAssertTrue(sut.removeVertex(edge.from, date: newerDate))
        XCTAssertEqual(sut.edges.count, 0, "Expect vertex to remove invalid edges when a vertex is removed")
    }

    func testAddEdge() {
        let date = firstEdgePair.date
        let edge = firstEdgePair.edge

        XCTAssertFalse(sut.addEdge(edge, date: date) , "Expect edge not to be added if the vertices don't exists")

        sut.addVertex(edge.from, date: date)
        sut.addVertex(edge.to, date: date)
        XCTAssertTrue(sut.addEdge(edge, date: date), "Expect edge to be added if the vertices exists")
    }

    func testRemoveEdge() {
        let date = firstEdgePair.date
        let edge = firstEdgePair.edge
        sut.addVertex(edge.from, date: date)
        sut.addVertex(edge.to, date: date)
        sut.addEdge(firstEdgePair.edge, date: date)

        XCTAssertTrue(sut.removeEdge(edge, date: date), "Expect edge to be remove")
        XCTAssertEqual(sut.vertices.count, 0, "Expect vertices without any edge to be remove")
    }

    func testExistsVertex() {
        let date = firstEdgePair.date
        let edge = firstEdgePair.edge
        let vertex = edge.from

        XCTAssertFalse(sut.existsVertex(vertex), "Expect vertex not to be exist before adding it")
        sut.addVertex(edge.from, date: date)
        XCTAssertTrue(sut.existsVertex(vertex), "Expect vertex to be exist after adding it")
    }
}
