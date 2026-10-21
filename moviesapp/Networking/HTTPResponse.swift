import Foundation

struct HTTPResponse<Value> {
    let value: Value
    let metadata: HTTPMetadata
}

struct HTTPMetadata: Sendable {
    let statusCode: Int
    let networkHeaders: [String: String]
}

extension HTTPURLResponse {
    var normalizedHeaders: [String: String] {
        allHeaderFields.reduce(into: [:]) { result, pair in
            result[String(describing: pair.key).lowercased()] = String(describing: pair.value)
        }
    }
}
