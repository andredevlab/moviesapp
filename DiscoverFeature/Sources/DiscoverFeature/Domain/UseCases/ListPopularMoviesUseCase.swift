import Core

public protocol ListPopularMoviesUseCase: Sendable {
    func execute(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie>
}
