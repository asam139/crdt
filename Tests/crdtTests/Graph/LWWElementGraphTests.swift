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

    func testVerticesFromAnother() {
        let firstPair: TestEdgePair = (Date(), .init(from: 1, to: 2))
        let secondPair: TestEdgePair = (Date(), .init(from: 1, to: 3))

        let firstDate = firstPair.date
        let firstEdge = firstPair.edge
        let secondDate = secondPair.date
        let secondEdge = secondPair.edge

        sut.addVertex(firstEdge.from, date: firstDate)
        XCTAssertEqual(sut.vertices(from: firstEdge.from).count, 0, "Expect vertex not to have neighbours before adding none")

        sut.addVertex(firstEdge.to, date: firstDate)
        sut.addEdge(firstEdge, date: firstDate)
        XCTAssertEqual(sut.vertices(from: firstEdge.from).count, 1, "Expect vertex to have 1 neighbour after adding one edge")

        sut.addVertex(secondEdge.from, date: secondDate)
        sut.addVertex(secondEdge.to, date: secondDate)
        sut.addEdge(secondEdge, date: secondDate)
        XCTAssertEqual(sut.vertices(from: firstEdge.from).count, 2, "Expect vertex to have 2 neighbours after adding two edge")
    }

    func testEdgesFromVertex() {
        let firstPair: TestEdgePair = (Date(), .init(from: 1, to: 2))
        let secondPair: TestEdgePair = (Date(), .init(from: 1, to: 3))

        let firstDate = firstPair.date
        let firstEdge = firstPair.edge
        let secondDate = secondPair.date
        let secondEdge = secondPair.edge

        sut.addVertex(firstEdge.from, date: firstDate)
        XCTAssertEqual(sut.edges(from: firstEdge.from).count, 0, "Expect vertex not to have edges before adding none")

        sut.addVertex(firstEdge.to, date: firstDate)
        sut.addEdge(firstEdge, date: firstDate)
        XCTAssertEqual(sut.edges(from: firstEdge.from).count, 1, "Expect vertex to have 1 neighbour after adding one edge")

        sut.addVertex(secondEdge.from, date: secondDate)
        sut.addVertex(secondEdge.to, date: secondDate)
        sut.addEdge(secondEdge, date: secondDate)
        XCTAssertEqual(sut.edges(from: firstEdge.from).count, 2, "Expect vertex to have 2 neighbours after adding two edge")
    }

    func testPathBetweenTwoVertex() {
        let firstPair: TestEdgePair = (Date(), .init(from: 1, to: 2))
        let secondPair: TestEdgePair = (Date(), .init(from: 2, to: 3))
        let thirdPair: TestEdgePair = (Date(), .init(from: 1, to: 4))

        let from = firstPair.edge.from
        let to = secondPair.edge.to

        XCTAssertNil(sut.path(from: from, to: to), "Expect graph not to have paths between two vertices not to be added")

        // Add first edge
        sut.addVertex(firstPair.edge.from, date: firstPair.date)
        sut.addVertex(firstPair.edge.to, date: firstPair.date)
        sut.addEdge(firstPair.edge, date: firstPair.date)
        XCTAssertNil(sut.path(from: from, to: to), "Expect graph not to found any path")

        // Add second edge
        sut.addVertex(secondPair.edge.from, date: secondPair.date)
        sut.addVertex(secondPair.edge.to, date: secondPair.date)
        sut.addEdge(secondPair.edge, date: secondPair.date)
        XCTAssertNotNil(sut.path(from: from, to: to), "Expect graph to found path")

        // Add third edge
        sut.addVertex(thirdPair.edge.from, date: thirdPair.date)
        sut.addVertex(thirdPair.edge.to, date: thirdPair.date)
        sut.addEdge(thirdPair.edge, date: thirdPair.date)
        XCTAssertNotNil(sut.path(from: from, to: to), "Expect graph to found path")

        // Remove second vertex (also the edge)
        sut.removeVertex(secondPair.edge.to, date: .distantFuture)
        XCTAssertNil(sut.path(from: from, to: to), "Expect not to found any path")
    }

    func testMergeGraph() {
        let firstPair: TestEdgePair = (Date(), .init(from: 1, to: 2))
        let secondPair: TestEdgePair = (Date(), .init(from: 2, to: 3))

        // Prepare first graph
        sut.addVertex(firstPair.edge.from, date: firstPair.date)
        sut.addVertex(firstPair.edge.to, date: firstPair.date)
        sut.addEdge(firstPair.edge, date: firstPair.date)

        // Prepare second graph
        var secondGraph = LWWElementGraph<Int>()
        secondGraph.addVertex(secondPair.edge.from, date: secondPair.date)
        secondGraph.addVertex(secondPair.edge.to, date: secondPair.date)
        secondGraph.addEdge(secondPair.edge, date: secondPair.date)

        sut.merge(secondGraph)
        let from = firstPair.edge.from
        let to = secondPair.edge.to
        XCTAssertNotNil(sut.path(from: from, to: to), "Expect graph to found path")

        secondGraph.removeEdge(secondPair.edge, date: .distantFuture)
        sut.merge(secondGraph)
        XCTAssertNil(sut.path(from: from, to: to), "Expect graph not to found path")
    }
}
