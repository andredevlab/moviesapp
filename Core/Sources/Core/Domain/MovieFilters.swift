import Foundation

public struct MovieFilters: Equatable, Hashable, Sendable {
    public var year: Int?
    public var genre: MovieGenre?

    public var isEmpty: Bool { year == nil && genre == nil }

    public init(year: Int? = nil, genre: MovieGenre? = nil) {
        self.year = year
        self.genre = genre
    }
}

