import Foundation

struct TraktMoviesRequest<Response: Decodable>: APIRequest {
    let path: String
    let queryItems: [URLQueryItem]

    init(path: String, query: MovieQuery, page: Int, limit: Int) {
        self.path = path
        var items = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "extended", value: "full")
        ]
        if !query.term.isEmpty {
            items.append(URLQueryItem(name: "query", value: query.term))
        } else {
            if let year = query.filters.year { items.append(URLQueryItem(name: "years", value: String(year))) }
            if let genre = query.filters.genre { items.append(URLQueryItem(name: "genres", value: genre.rawValue)) }
        }
        queryItems = items
    }
}

struct TraktMovieDTO: Decodable, Sendable {
    struct IDs: Decodable, Sendable { let trakt: Int }

    let ids: IDs
    let title: String
    let year: Int?
    let overview: String?
    let runtime: Int?
    let genres: [String]?

    var movie: Movie {
        Movie(id: ids.trakt, title: title, year: year, overview: overview,
              runtime: runtime, genres: genres ?? [])
    }
}

struct TraktSearchResultDTO: Decodable, Sendable {
    let movie: TraktMovieDTO
}
