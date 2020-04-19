import DadJokesCoreTests
import DadJokesTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += DadJokesCoreTests.allTests()
tests += DadJokesTests.allTests()
XCTMain(tests)
