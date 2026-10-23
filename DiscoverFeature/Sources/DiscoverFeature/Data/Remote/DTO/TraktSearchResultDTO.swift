import Core
import Foundation

struct TraktSearchResultDTO: Decodable, Sendable {
    let movie: TraktMovieDTO
}
