import XCTest

import crdtTests

var tests = [XCTestCaseEntry]()
tests += crdtTests.allTests()
XCTMain(tests)
