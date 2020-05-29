import GCDWebServer
import LoremIpsum
import XCTest

import class Foundation.Bundle

final class DadJokeCommandTests: XCTestCase {

    enum TestErrors: Error {
        case couldNotFindBundleURL
    }

    var server: GCDWebServer?

    override func setUpWithError() throws {
        try super.setUpWithError()

        server = GCDWebServer()

        let server = try XCTUnwrap(self.server)

        XCTAssertTrue(server.start(withPort: 8080, bonjourName: nil))
    }

    override func tearDown() {
        server?.stop()
        server = nil
    }

    func testHappyPath() throws {
        let server = try XCTUnwrap(self.server)
        let serverURL = try XCTUnwrap(server.serverURL)

        let process = try appProcess(["-u", serverURL.absoluteString])

        let joke = LoremIpsum.sentence

        server.addDefaultHandler(forMethod: "GET") { _ in
            return GCDWebServerDataResponse(jsonObject: [
                "joke": joke,
                "status": 200,
                "id": UUID().uuidString
            ])
        }

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }

        process.waitUntilExit()

        let outputData: Data
        let errorData: Data

        if #available(macOS 10.15, *) {
            outputData = try XCTUnwrap(
                try outputPipe.fileHandleForReading.readToEnd()
            )
        } else {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        }

        let output = String(data: outputData, encoding: .utf8)

        if #available(macOS 10.15, *) {
            XCTAssertNil(try errorPipe.fileHandleForReading.readToEnd())
        } else {
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            XCTAssertTrue(errorData.isEmpty)
        }

        XCTAssertEqual(output, "\(joke)\n")
    }

    func testFailureReceived() throws {
        let server = try XCTUnwrap(self.server)
        let serverURL = try XCTUnwrap(server.serverURL)

        let process = try appProcess(["-u", serverURL.absoluteString])

        server.addDefaultHandler(
            forMethod: "GET",
            request: GCDWebServerRequest.self) { _ in
                return .init(statusCode: 500)
        }

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }

        process.waitUntilExit()

        let outputData: Data
        let errorData: Data

        if #available(macOS 10.15, *) {
            XCTAssertNil(try outputPipe.fileHandleForReading.readToEnd())
        } else {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            XCTAssertTrue(outputData.isEmpty)
        }

        if #available(macOS 10.15, *) {
            errorData = try XCTUnwrap(
                try errorPipe.fileHandleForReading.readToEnd()
            )
        } else {
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }

        let error = String(data: errorData, encoding: .utf8)

        XCTAssertEqual(
            error,
            "Error: Response status code was unacceptable: 500.\n"
        )
    }

    func testEmptyOutput() throws {
        let server = try XCTUnwrap(self.server)
        let serverURL = try XCTUnwrap(server.serverURL)

        let process = try appProcess(["-u", serverURL.absoluteString])

        server.addDefaultHandler(
            forMethod: "GET",
            request: GCDWebServerRequest.self) { _ in
                return .init(statusCode: 200)
        }

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }

        process.waitUntilExit()

        let outputData: Data
        let errorData: Data

        if #available(macOS 10.15, *) {
            XCTAssertNil(try outputPipe.fileHandleForReading.readToEnd())
        } else {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            XCTAssertTrue(outputData.isEmpty)
        }

        if #available(macOS 10.15, *) {
            errorData = try XCTUnwrap(
                try errorPipe.fileHandleForReading.readToEnd()
            )
        } else {
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }

        let error = String(data: errorData, encoding: .utf8)

        XCTAssertEqual(
            error,
            "Error: Response could not be serialized, input data was nil or zero length.\n"
        )
    }

    func testTimeout() throws {
        let server = try XCTUnwrap(self.server)
        let serverURL = try XCTUnwrap(server.serverURL)

        let process = try appProcess(
            ["-u", serverURL.absoluteString, "-t", "2"]
        )

        server.addDefaultHandler(forMethod: "GET") { _, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(4)) {
                completion(GCDWebServerDataResponse(jsonObject: [
                    "joke": "What do you call a fish with no eyes? A fsh!",
                    "status": 200,
                    "id": UUID().uuidString
                ]))
            }
        }

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }

        process.waitUntilExit()

        let outputData: Data
        let errorData: Data

        if #available(macOS 10.15, *) {
            XCTAssertNil(try outputPipe.fileHandleForReading.readToEnd())
        } else {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            XCTAssertTrue(outputData.isEmpty)
        }

        if #available(macOS 10.15, *) {
            errorData = try XCTUnwrap(
                try errorPipe.fileHandleForReading.readToEnd()
            )
        } else {
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }

        let error = try XCTUnwrap(String(data: errorData, encoding: .utf8))

        XCTAssertFalse(error.isEmpty)
    }

    /// Returns a `Process` for the app binary with the given arguments.
    private func appProcess(
        _ launchArguments: [String] = []
    ) throws -> Process {
        let productsDirectory = try self.productsDirectory()
        let appBinary = productsDirectory.appendingPathComponent("DadJokes")

        let process = Process()

        if #available(macOS 10.13, *) {
            process.executableURL = appBinary
        } else {
            process.launchPath = appBinary.path
        }

        if !launchArguments.isEmpty { process.arguments = launchArguments }

        return process
    }

    /// Returns path to the built products directory.
    private func productsDirectory() throws -> URL {
      #if os(macOS)
        guard let url = Bundle.allBundles
            .first(where: { $0.bundlePath.hasSuffix(".xctest") })?
            .bundleURL
            .deletingLastPathComponent()
            else { throw TestErrors.couldNotFindBundleURL }

        return url
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testHappyPath", testHappyPath),
        ("testFailureReceived", testFailureReceived),
        ("testEmptyOutput", testEmptyOutput),
        ("testTimeout", testTimeout)
    ]

}
