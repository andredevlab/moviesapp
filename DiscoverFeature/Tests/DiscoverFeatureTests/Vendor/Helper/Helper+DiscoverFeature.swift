import Core
@testable import DiscoverFeature

extension Helper {
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
