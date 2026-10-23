import Core

public actor ConcreteMoviesRepository: MoviesRepository {
    private let remoteDataSource: any MoviesRemoteDataSource

    init(remoteDataSource: any MoviesRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie> {
        let result = try await remoteDataSource.listPopular(filters: filters, page: page)
        return Page(items: result.items.map(map), pagination: result.pagination)
    }

    public func search(term: String, limit: Int) async throws -> MovieSearchResults {
        let movies = try await remoteDataSource.search(term: term, limit: limit)
        return MovieSearchResults(movies: movies.map(map), limit: limit)
    }

    private func map(_ movie: TraktMovieDTO) -> Movie {
        Movie(id: movie.ids.trakt,
              title: movie.title,
              year: movie.year,
              overview: movie.overview,
              runtime: movie.runtime,
              genres: movie.genres ?? [])
    }
}
