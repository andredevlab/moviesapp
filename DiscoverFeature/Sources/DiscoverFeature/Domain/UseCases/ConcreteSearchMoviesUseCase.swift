import Core

struct ConcreteSearchMoviesUseCase: SearchMoviesUseCase {
    private let repository: any MoviesRepository

    init(repository: any MoviesRepository) {
        self.repository = repository
    }

    func execute(term: String, limit: Int) async throws -> MovieSearchResults {
        try await repository.search(term: term, limit: limit)
    }
}
