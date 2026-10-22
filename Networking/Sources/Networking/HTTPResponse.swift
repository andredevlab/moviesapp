import Foundation

public struct HTTPResponse: Sendable {
    public let body: Data
    public let statusCode: Int
    public let headers: [String: String]

    public init(body: Data, statusCode: Int, headers: [String: String]) {
        self.body = body
        self.statusCode = statusCode
        self.headers = headers.reduce(into: [:]) { result, header in
            result[header.key.lowercased()] = header.value
        }
    }

    init(body: Data, response: HTTPURLResponse) {
        let headers = response.allHeaderFields.reduce(into: [String: String]()) { result, header in
            result[String(describing: header.key)] = String(describing: header.value)
        }
        self.init(body: body, statusCode: response.statusCode, headers: headers)
    }
}
