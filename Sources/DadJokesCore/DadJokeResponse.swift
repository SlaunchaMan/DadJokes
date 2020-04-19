import Foundation

public struct DadJokeResponse: Decodable {

    public let identifier: String
    public let joke: String
    public let status: Int

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case joke
        case status
    }

}
