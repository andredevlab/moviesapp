import Foundation

struct MoviePage: Equatable, Sendable {
    let movies: [Movie]
    let pagination: MoviePagination
}

struct MoviePagination: Equatable, Sendable {
    let page: Int
    let limit: Int
    let pageCount: Int
    let itemCount: Int

    var hasNextPage: Bool { page < pageCount }
}
