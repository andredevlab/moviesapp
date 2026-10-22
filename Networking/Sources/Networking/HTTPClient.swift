public protocol HTTPClient: Sendable {
    func send(_ request: any HTTPRequest) async throws -> HTTPResponse
}
