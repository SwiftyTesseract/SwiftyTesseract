import XCTest

import cliTests

var tests = [XCTestCaseEntry]()
tests += cliTests.allTests()
XCTMain(tests)
