import Core
import Foundation

struct TraktAPIRequestConfiguration {
    static func headers(clientID: String) -> [String: String] {
        [ "Content-Type": "application/json",
          "Accept": "application/json",
          "User-Agent": "moviesapp/1.0",
          "trakt-api-key": clientID,
          "trakt-api-version": "2"]
    }
    
    static func url(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(string: "https://api.trakt.tv/" + path) else {
            throw MoviesRemoteDataSourceError.invalidURL
        }
        components.queryItems = queryItems
        // Trakt interprets literal + as a space unless it is percent-encoded.
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+",
                                                                                              with: "%2B")
        guard let url = components.url else { throw MoviesRemoteDataSourceError.invalidURL }
        return url
    }
}
