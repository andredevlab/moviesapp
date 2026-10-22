import Foundation

public protocol HTTPRequest: Sendable {
    var method: String { get }
    var url: URL { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}
