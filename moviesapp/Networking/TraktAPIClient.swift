import Foundation

@MainActor
final class TraktAPIClient: APIClient {
    private let baseURL: URL
    private let clientID: String
    private let transport: any HTTPTransport
    private let diagnostics: RequestDiagnostics

    init(
        clientID: String,
        transport: any HTTPTransport,
        diagnostics: RequestDiagnostics,
        baseURL: URL = URL(string: "https://api.trakt.tv")!
    ) {
        self.clientID = clientID
        self.transport = transport
        self.diagnostics = diagnostics
        self.baseURL = baseURL
    }

    func send<Request: APIRequest>(_ request: Request) async throws -> HTTPResponse<Request.Response> {
        guard !clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.missingClientID
        }
        let urlRequest = try makeURLRequest(request)

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await transport.data(for: urlRequest)
        } catch {
            diagnostics.record(request: urlRequest, response: nil, byteCount: 0, failure: error.localizedDescription)
            throw error
        }

        let headers = response.normalizedHeaders
        diagnostics.record(request: urlRequest, response: response, byteCount: data.count)
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.http(status: response.statusCode, headers: headers)
        }

        try Task.checkCancellation()
        let value: Request.Response
        do {
            value = try JSONDecoder().decode(Request.Response.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
        return HTTPResponse(value: value, metadata: HTTPMetadata(
            statusCode: response.statusCode, networkHeaders: headers
        ))
    }

    private func makeURLRequest<Request: APIRequest>(_ request: Request) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = request.queryItems
        // Preserve literal + when the server interprets query strings as form data.
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else { throw NetworkError.invalidURL }
        var result = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        result.httpMethod = "GET"
        result.setValue("application/json", forHTTPHeaderField: "Content-Type")
        result.setValue("application/json", forHTTPHeaderField: "Accept")
        result.setValue("moviesapp/1.0", forHTTPHeaderField: "User-Agent")
        result.setValue(clientID, forHTTPHeaderField: "trakt-api-key")
        result.setValue("2", forHTTPHeaderField: "trakt-api-version")
        return result
    }
}
