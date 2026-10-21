import Foundation

@MainActor
final class TraktMoviesService: MoviesServicing {
    private let client: any APIClient

    init(client: any APIClient) { self.client = client }

    func fetchMovies(query: MovieQuery, page: Int, limit: Int) async throws -> MoviePage {
        let movies: [Movie]
        let metadata: HTTPMetadata
        if query.term.isEmpty {
            let request = TraktMoviesRequest<[TraktMovieDTO]>(
                path: "movies/popular", query: query, page: page, limit: limit
            )
            let response = try await client.send(request)
            movies = response.value.map(\.movie)
            metadata = response.metadata
        } else {
            let request = TraktMoviesRequest<[TraktSearchResultDTO]>(
                path: "search/movie", query: query, page: page, limit: limit
            )
            let response = try await client.send(request)
            movies = response.value.map { $0.movie.movie }
            metadata = response.metadata
        }

        let headers = metadata.networkHeaders
        guard let actualPage = headers["x-pagination-page"].flatMap(Int.init), actualPage == page,
              let actualLimit = headers["x-pagination-limit"].flatMap(Int.init), actualLimit > 0,
              let pageCount = headers["x-pagination-page-count"].flatMap(Int.init), pageCount >= 0,
              let itemCount = headers["x-pagination-item-count"].flatMap(Int.init), itemCount >= 0,
              actualPage > 0, pageCount >= actualPage || (page == 1 && pageCount == 0 && itemCount == 0)
        else { throw NetworkError.invalidPagination }

        guard actualLimit == limit, movies.count <= limit else {
            throw NetworkError.unexpectedPageSize(requested: limit, effective: actualLimit, received: movies.count)
        }
        return MoviePage(movies: movies, pagination: MoviePagination(
            page: actualPage, limit: actualLimit, pageCount: pageCount, itemCount: itemCount
        ))
    }
}
