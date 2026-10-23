import Core

public protocol SearchMoviesUseCase: Sendable {
    func execute(term: String, limit: Int) async throws -> MovieSearchResults
}
