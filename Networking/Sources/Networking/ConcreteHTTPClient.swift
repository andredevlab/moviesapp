import Foundation

actor ConcreteHTTPClient: HTTPClient {
    private let transport: any HTTPTransport
    
    init(transport: any HTTPTransport) {
        self.transport = transport
    }
    
    func send(_ request: any HTTPRequest) async throws -> HTTPResponse {
        let requestURL = request.url
        let queryItems = request.queryItems
        let url = queryItems.isEmpty ? requestURL : requestURL.appending(queryItems: queryItems)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        urlRequest.httpBody = request.body
        
        let body: Data
        let response: HTTPURLResponse
        do {
            (body, response) = try await transport.data(for: urlRequest)
        } catch {
            if error is CancellationError || (error as? URLError)?.code == .cancelled || Task.isCancelled {
                throw CancellationError()
            }
            throw (error as? HTTPError) ?? .transport(underlying: error)
        }
        
        let result = HTTPResponse(body: body, response: response)
        let isSuccess = (200..<300).contains(result.statusCode)
        
        guard isSuccess else {
            throw HTTPError.http(statusCode: result.statusCode,
                                 headers: result.headers)
        }
        
        return result
    }
}
