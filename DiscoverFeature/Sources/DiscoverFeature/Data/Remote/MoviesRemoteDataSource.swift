import Core

protocol MoviesRemoteDataSource: Sendable {
    func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<TraktMovieDTO>
    func search(term: String, limit: Int) async throws -> [TraktMovieDTO]
}
