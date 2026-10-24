import Core
@testable import DiscoverFeature

extension Helper {
    static func makeTraktMovieDetailDTO(traktID: Int = -1111,
                                       title: String = "",
                                       year: Int? = nil,
                                       overview: String? = nil,
                                       runtime: Int? = nil,
                                       genres: [String]? = nil,
                                       images: TraktMovieDetailDTO.Images? = nil,
                                       originalTitle: String? = nil,
                                       tagline: String? = nil,
                                       released: String? = nil,
                                       country: String? = nil,
                                       language: String? = nil,
                                       languages: [String]? = nil,
                                       status: String? = nil,
                                       rating: Double? = nil,
                                       votes: Int? = nil,
                                       certification: String? = nil,
                                       trailer: String? = nil,
                                       homepage: String? = nil,
                                       afterCredits: Bool? = nil,
                                       duringCredits: Bool? = nil) -> TraktMovieDetailDTO {
        TraktMovieDetailDTO(ids: .init(trakt: traktID), title: title, year: year,
                            overview: overview, runtime: runtime, genres: genres, images: images,
                            originalTitle: originalTitle, tagline: tagline, released: released,
                            country: country, language: language, languages: languages,
                            status: status, rating: rating, votes: votes, certification: certification,
                            trailer: trailer, homepage: homepage,
                            afterCredits: afterCredits, duringCredits: duringCredits)
    }

    static func makeTraktMovieDTO(traktID: Int = -1111,
                                  title: String = "",
                                  year: Int? = nil,
                                  overview: String? = nil,
                                  runtime: Int? = nil,
                                  genres: [String]? = nil,
                                  images: TraktMovieDTO.Images? = nil) -> TraktMovieDTO {
        TraktMovieDTO(ids: .init(trakt: traktID),
                      title: title,
                      year: year,
                      overview: overview,
                      runtime: runtime,
                      genres: genres,
                      images: images)
    }
    
}
