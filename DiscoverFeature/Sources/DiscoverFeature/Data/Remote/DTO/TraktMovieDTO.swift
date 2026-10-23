import Core
import Foundation

struct TraktMovieDTO: Decodable, Sendable {
    struct IDs: Decodable, Sendable {
        let trakt: Int
    }

    let ids: IDs
    let title: String
    let year: Int?
    let overview: String?
    let runtime: Int?
    let genres: [String]?
}
