import Foundation

public enum HTTPError: Error, Sendable, LocalizedError {
    case nonHTTPResponse
    case transport(underlying: any Error)
    case http(statusCode: Int, headers: [String: String])

    public var errorDescription: String? {
        switch self {
        case .nonHTTPResponse:
            "O transporte retornou uma resposta que não é HTTP."
        case let .transport(underlying):
            if let error = underlying as? URLError {
                "Falha no transporte HTTP (código \(error.code.rawValue))."
            } else {
                "Falha no transporte HTTP."
            }
        case let .http(statusCode, _):
            "O servidor retornou HTTP \(statusCode)."
        }
    }
}
