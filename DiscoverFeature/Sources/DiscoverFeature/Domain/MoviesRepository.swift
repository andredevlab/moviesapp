import Core
import Foundation

public protocol MoviesRepository: Sendable {
    func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie>

    /// Searches the first window only, with a nonblank term and positive limit.
    /// Implementations must reject invalid input rather than fall back to popular movies.
    func search(term: String, limit: Int) async throws -> MovieSearchResults
}
