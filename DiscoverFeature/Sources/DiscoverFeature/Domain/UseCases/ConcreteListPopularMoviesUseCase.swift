import Core

struct ConcreteListPopularMoviesUseCase: ListPopularMoviesUseCase {
    private let repository: any MoviesRepository

    init(repository: any MoviesRepository) {
        self.repository = repository
    }

    func execute(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie> {
        try await repository.listPopular(filters: filters, page: page)
    }
}
