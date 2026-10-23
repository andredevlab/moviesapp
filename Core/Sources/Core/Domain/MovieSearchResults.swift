import Foundation

/// A bounded search window without continuation or a global total.
public struct MovieSearchResults: Equatable, Sendable {
    public let movies: [Movie]
    public let limit: Int

    public init(movies: [Movie], limit: Int) {
        self.movies = movies
        self.limit = limit
    }
}
