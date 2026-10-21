import Foundation

enum NetworkError: LocalizedError {
    case missingClientID
    case invalidURL
    case nonHTTPResponse
    case http(status: Int, headers: [String: String])
    case decoding
    case invalidPagination
    case unexpectedPageSize(requested: Int, effective: Int, received: Int)

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            "Configure TRAKT_CLIENT_ID nas variáveis de ambiente do scheme no Xcode e abra o app novamente."
        case .invalidURL:
            "Não foi possível montar a URL da requisição."
        case .nonHTTPResponse:
            "O servidor retornou uma resposta que não é HTTP."
        case let .http(status, headers):
            if status == 429, let retryAfter = headers["retry-after"] {
                "Limite de requisições atingido (HTTP 429). Retry-After: \(retryAfter)."
            } else {
                "O Trakt retornou HTTP \(status). Consulte os detalhes em Requisições."
            }
        case .decoding:
            "O formato da resposta não corresponde ao contrato esperado."
        case .invalidPagination:
            "Os headers de paginação estão ausentes ou inconsistentes. Consulte Requisições."
        case let .unexpectedPageSize(requested, effective, received):
            "Limite solicitado: \(requested); efetivo: \(effective); recebidos: \(received). A resposta não atende ao limite da POC."
        }
    }
}
