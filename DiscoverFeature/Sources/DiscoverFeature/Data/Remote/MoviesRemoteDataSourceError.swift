import Core
import Foundation

enum MoviesRemoteDataSourceError: Error, Sendable, LocalizedError {
    case invalidSearchTerm
    case invalidLimit
    case invalidURL
    case decoding
    case invalidPagination
    case unexpectedPageSize(requested: Int, effective: Int, received: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidSearchTerm:
            "Informe um termo de busca não vazio."
        case .invalidLimit:
            "O limite deve ser maior que zero."
        case .invalidURL:
            "Não foi possível montar a URL da requisição."
        case .decoding:
            "O formato da resposta não corresponde ao contrato esperado."
        case .invalidPagination:
            "Os headers de paginação estão ausentes ou inconsistentes."
        case let .unexpectedPageSize(requested, effective, received):
            "Limite solicitado: \(requested); efetivo: \(effective); recebidos: \(received). A resposta não atende ao limite solicitado."
        }
    }
}
