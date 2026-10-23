import Core

extension Helper {
    static func makePage<Element: Sendable>(items: [Element] = [],
                                            pagination: Pagination = Helper.makePagination()) -> Page<Element> {
        Page(items: items, pagination: pagination)
    }
    
    static func makePagination(page: Int = -1111,
                               limit: Int = -1111,
                               pageCount: Int = -1111,
                               itemCount: Int = -1111) -> Pagination {
        Pagination(page: page, limit: limit, pageCount: pageCount, itemCount: itemCount)
    }
    

    static func makeMovieFilters(year: Int? = nil, genre: MovieGenre? = nil) -> MovieFilters {
        MovieFilters(year: year, genre: genre)
    }
    
    static func makePageRequest(page: Int = -1111, limit: Int = -1111) throws -> PageRequest {
        try PageRequest(page: page, limit: limit)
    }
    static func makeMovie(id: Int = -1111,
                          title: String = "",
                          year: Int? = nil,
                          overview: String? = nil,
                          runtime: Int? = nil,
                          genres: [String] = []) -> Movie {
        Movie(id: id, title: title, year: year, overview: overview, runtime: runtime, genres: genres)
    }

}
