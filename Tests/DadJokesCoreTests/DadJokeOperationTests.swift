import Alamofire
import DadJokesCore
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

final class DadJokeOperationTests: XCTestCase {

    class override func tearDown() {
        HTTPStubs.removeAllStubs()

        super.tearDown()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()

        super.tearDown()
    }

    func testHappyPath() throws {

        let url = try XCTUnwrap(URL(string: "https://www.example.com"))

        stub(condition: {
            $0.url == url &&
                $0.allHTTPHeaderFields?["Accept"] == "application/json"
        },
             response: { _ in
                .init(
                    jsonObject: [
                        "id": UUID().uuidString,
                        "joke": "Why did the chicken cross the road?",
                        "status": 200
                    ],
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        })

        let operation = DadJokeOperation(timeoutInterval: 5, url: url)

        let expect = expectation(description: "The task finishes")

        operation.completionBlock = expect.fulfill

        OperationQueue().addOperation(operation)

        wait(for: [expect], timeout: 2)

        XCTAssertEqual(try operation.output?.get(),
                       "Why did the chicken cross the road?")

    }

    func testDecodingError() throws {

        let url = try XCTUnwrap(URL(string: "https://www.example.com"))

        stub(condition: {
            $0.url == url &&
                $0.allHTTPHeaderFields?["Accept"] == "application/json"
        },
             response: { _ in
                .init(
                    jsonObject: [
                        "malformed_id": UUID().uuidString,
                        "malformed_joke": "Why did the chicken cross the road?",
                        "malformed_status": 200
                    ],
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        })

        let operation = DadJokeOperation(timeoutInterval: 5, url: url)

        let expect = expectation(description: "The task finishes")

        operation.completionBlock = expect.fulfill

        OperationQueue().addOperation(operation)

        wait(for: [expect], timeout: 2)

        let result = try XCTUnwrap(operation.output)

        switch result {
        case .success:
            XCTFail("Should not have parsed a joke.")
        case .failure(let error):
            let afError = try XCTUnwrap(error as? AFError)

            switch afError {
            case .responseSerializationFailed:
                break // Expected behavior
            default:
                XCTFail("Expected error to be response serialization failed")
            }
        }

    }

    func testServerError() throws {

        let url = try XCTUnwrap(URL(string: "https://www.example.com"))

        stub(condition: {
            $0.url == url &&
                $0.allHTTPHeaderFields?["Accept"] == "application/json"
        },
             response: { _ in
                .init(jsonObject: ["status": 500],
                      statusCode: 500,
                      headers: nil)
        })

        let operation = DadJokeOperation(timeoutInterval: 5, url: url)

        let expect = expectation(description: "The task finishes")

        operation.completionBlock = expect.fulfill

        OperationQueue().addOperation(operation)

        wait(for: [expect], timeout: 2)

        let result = try XCTUnwrap(operation.output)

        switch result {
        case .success:
            XCTFail("Should not have parsed a joke.")
        case .failure(let error):
            let afError = try XCTUnwrap(error as? AFError)

            switch afError {
            case .responseValidationFailed:
                break // expected behavior
            default:
                XCTFail("Expected error to be response validation failed")
            }
        }

    }

    func testFailureReceived() throws {

        let url = try XCTUnwrap(URL(string: "https://www.example.com"))

        stub(condition: {
            $0.url == url &&
                $0.allHTTPHeaderFields?["Accept"] == "application/json"
        },
             response: { _ in
                .init(error: URLError(.badServerResponse))
        })

        let operation = DadJokeOperation(timeoutInterval: 5, url: url)

        let expect = expectation(description: "The task finishes")

        operation.completionBlock = expect.fulfill

        OperationQueue().addOperation(operation)

        wait(for: [expect], timeout: 2)

        let result = try XCTUnwrap(operation.output)

        switch result {
        case .success:
            XCTFail("Should not have parsed a joke.")
        case .failure(let error):
            let afError = try XCTUnwrap(error as? AFError)

            switch afError {
            case .sessionTaskFailed(let error):
                XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
            default:
                XCTFail("Expected error to be session task failed")
            }
        }

    }

    func testTimeout() throws {

        let url = try XCTUnwrap(URL(string: "https://www.example.com"))

        stub(condition: {
            $0.url == url &&
                $0.allHTTPHeaderFields?["Accept"] == "application/json" &&
                $0.timeoutInterval == 2
        },
             response: { _ in
                .init(error: URLError(.timedOut))
        })

        let operation = DadJokeOperation(timeoutInterval: 2, url: url)

        let expect = expectation(description: "The task finishes")

        operation.completionBlock = expect.fulfill

        OperationQueue().addOperation(operation)

        wait(for: [expect], timeout: 2)

        let result = try XCTUnwrap(operation.output)

        switch result {
        case .success:
            XCTFail("Should not have parsed a joke.")
        case .failure(let error):
            let afError = try XCTUnwrap(error as? AFError)

            switch afError {
            case .sessionTaskFailed(let error):
                XCTAssertEqual((error as? URLError)?.code, .timedOut)
            default:
                XCTFail("Expected error to be session task failed")
            }
        }

    }

    static var allTests = [
        ("testHappyPath", testHappyPath),
        ("testDecodingError", testDecodingError),
        ("testServerError", testServerError),
        ("testFailureReceived", testFailureReceived),
        ("testTimeout", testTimeout)
    ]

}
