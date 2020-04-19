import ArgumentParser
import DadJokesCore
import Foundation

struct DadJokeCommand: ParsableCommand {

    static var configuration = CommandConfiguration(commandName: "dadjokes")

    @Option(name: .shortAndLong,
            default: 60,
            help: "The time (in seconds) to wait for a response.")
    var timeout: TimeInterval

    @Option(name: .shortAndLong,
            default: URL(string: "https://icanhazdadjoke.com"),
            help: "The URL from which to fetch dad jokes.")
    var url: URL

    func run() throws {
        let operation = DadJokeOperation(timeoutInterval: timeout,
                                         url: url)

        OperationQueue().addOperations([operation], waitUntilFinished: true)

        switch operation.output {
        case .success(let joke):
            print(joke)
        case .failure(let error):
            throw error
        default:
            throw ValidationError("No output received")
        }

    }

}

extension URL: ExpressibleByArgument {

    public init?(argument: String) {
        self.init(string: argument)
    }

}
