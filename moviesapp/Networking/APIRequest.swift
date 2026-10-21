import Foundation

protocol APIRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

@MainActor
protocol APIClient {
    func send<Request: APIRequest>(_ request: Request) async throws -> HTTPResponse<Request.Response>
}

@MainActor
protocol HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

@MainActor
final class URLSessionTransport: HTTPTransport {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpShouldSetCookies = false
        session = URLSession(configuration: configuration)
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.nonHTTPResponse
        }
        return (data, httpResponse)
    }
}
