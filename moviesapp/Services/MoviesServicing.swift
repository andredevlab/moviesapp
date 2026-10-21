import Foundation

@MainActor
protocol MoviesServicing {
    func fetchMovies(query: MovieQuery, page: Int, limit: Int) async throws -> MoviePage
}
