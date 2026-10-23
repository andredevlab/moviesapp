import Foundation
import Networking

struct TraktSearchMoviesRequest: HTTPRequest {
    let method = "GET"
    let url: URL
    let queryItems: [URLQueryItem] = []
    let headers: [String: String]
    let body: Foundation.Data? = nil
    
    init(term: String, limit: Int, clientID: String) throws {
        var items = [URLQueryItem(name: "page", value: "1"),
                     URLQueryItem(name: "limit", value: String(limit)),
                     URLQueryItem(name: "extended", value: "full"),
                     URLQueryItem(name: "query", value: term)]
        
        url = try TraktAPIRequestConfiguration.url(path: "search/movie",
                                                queryItems: items)
        headers = TraktAPIRequestConfiguration.headers(clientID: clientID)
    }
}
