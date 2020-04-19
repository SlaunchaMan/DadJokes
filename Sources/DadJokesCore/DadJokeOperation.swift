import Alamofire
import Foundation

public final class DadJokeOperation: Operation {

    private let queue = DispatchQueue(label: "com.slaunchaman.dadjokeoperation")
    private let session: Session
    private let timeoutInterval: TimeInterval
    private let url: URL

    private var _isExecuting = false {
        willSet {
            willChangeValue(for: \.isExecuting)
        }
        didSet {
            didChangeValue(for: \.isExecuting)
        }
    }

    private var _isFinished = false {
        willSet {
            willChangeValue(for: \.isFinished)
        }
        didSet {
            didChangeValue(for: \.isFinished)
        }
    }

    public var output: Result<String, Error>?

    public init(timeoutInterval: TimeInterval = 60, url: URL) {
        session = Session(configuration: .ephemeral)
        self.timeoutInterval = timeoutInterval
        self.url = url

        super.init()
    }

    public override func start() {
        let timeoutInterval = self.timeoutInterval

        AF.request(
            url,
            headers: HTTPHeaders([
                .accept("application/json"),
                .userAgent("DadJokes (https://github.com/SlaunchaMan/DadJokes)")
            ])
        ) {
            $0.timeoutInterval = timeoutInterval
        }
        .validate()
        .responseDecodable(of: DadJokeResponse.self, queue: queue) { response in
            defer { self.finish() }

            let jokeResult = response.result
                .map(\.joke)
                .mapError { $0 as Error }

            self.output = jokeResult
        }
    }

    public override var isAsynchronous: Bool { true }

    public override var isExecuting: Bool { _isExecuting }

    public override var isFinished: Bool { _isFinished }

    private func finish() {
        _isExecuting = false
        _isFinished = true
    }

}
