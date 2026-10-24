struct TraktMovieDetailDTO: Decodable, Sendable {
    struct IDs: Decodable, Sendable {
        let trakt: Int
    }

    struct Images: Decodable, Sendable {
        let poster: [String]?
    }

    let ids: IDs
    let title: String
    let year: Int?
    let overview: String?
    let runtime: Int?
    let genres: [String]?
    let images: Images?
    let originalTitle: String?
    let tagline: String?
    let released: String?
    let country: String?
    let language: String?
    let languages: [String]?
    let status: String?
    let rating: Double?
    let votes: Int?
    let certification: String?
    let trailer: String?
    let homepage: String?
    let afterCredits: Bool?
    let duringCredits: Bool?

    enum CodingKeys: String, CodingKey {
        case ids, title, year, overview, runtime, genres, images
        case originalTitle = "original_title"
        case tagline, released, country, language, languages, status, rating, votes
        case certification, trailer, homepage
        case afterCredits = "after_credits"
        case duringCredits = "during_credits"
    }
}
