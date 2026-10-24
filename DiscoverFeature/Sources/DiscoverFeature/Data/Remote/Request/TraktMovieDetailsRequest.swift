import Core
import Foundation
import Networking

struct TraktMovieDetailsRequest: HTTPRequest {
    let method = "GET"
    let url: URL
    let queryItems: [URLQueryItem] = []
    let headers: [String: String]
    let body: Foundation.Data? = nil
    
    init(id: Movie.ID, clientID: String) throws {
        url = try TraktAPIRequestConfiguration.url(path: "movies/\(id)",
                                                   queryItems: [URLQueryItem(name: "extended",
                                                                             value: "full")])
        headers = TraktAPIRequestConfiguration.headers(clientID: clientID)
    }
}
