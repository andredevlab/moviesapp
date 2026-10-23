import Core
import Foundation
import Networking

struct TraktPopularMoviesRequest: HTTPRequest {
    let method = "GET"
    let url: URL
    let queryItems: [URLQueryItem] = []
    let headers: [String: String]
    let body: Foundation.Data? = nil
    
    init(filters: MovieFilters, page: PageRequest, clientID: String) throws {
        var items = [URLQueryItem(name: "page", value: String(page.page)),
                     URLQueryItem(name: "limit", value: String(page.limit)),
                     URLQueryItem(name: "extended", value: "full")]
        
        if let year = filters.year { items.append(URLQueryItem(name: "years",
                                                               value: String(year))) }
        if let genre = filters.genre { items.append(URLQueryItem(name: "genres",
                                                                 value: Self.slug(for: genre))) }
        url = try TraktAPIRequestConfiguration.url(path: "movies/popular",
                                                   queryItems: items)
        headers = TraktAPIRequestConfiguration.headers(clientID: clientID)
    }
    
    private static func slug(for genre: MovieGenre) -> String {
        switch genre {
        case .action: "action"
        case .adventure: "adventure"
        case .comedy: "comedy"
        case .drama: "drama"
        case .horror: "horror"
        case .scienceFiction: "science-fiction"
        case .thriller: "thriller"
        }
    }
}
