import Core

extension Helper {
    static func makeMovie(id: Int = -1111,
                          title: String = "",
                          year: Int? = nil,
                          overview: String? = nil,
                          runtime: Int? = nil,
                          genres: [String] = []) -> Movie {
        Movie(id: id, title: title, year: year, overview: overview, runtime: runtime, genres: genres)
    }

    static func makePagination(page: Int = -1111,
                               limit: Int = -1111,
                               pageCount: Int = -1111,
                               itemCount: Int = -1111) -> Pagination {
        Pagination(page: page, limit: limit, pageCount: pageCount, itemCount: itemCount)
    }

    static func makePage(items: [Movie] = [],
                         pagination: Pagination = Helper.makePagination()) -> Page<Movie> {
        Page(items: items, pagination: pagination)
    }
}
