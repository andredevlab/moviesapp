import Core
import Foundation

public struct MovieDetails: Equatable, Sendable {
    public let movie: Movie
    public let originalTitle: String?
    public let tagline: String?
    public let releaseDate: Date?
    public let country: String?
    public let language: String?
    public let languages: [String]
    public let status: String?
    public let rating: Double?
    public let votes: Int?
    public let certification: String?
    public let trailerURL: URL?
    public let homepageURL: URL?
    public let afterCredits: Bool?
    public let duringCredits: Bool?

    public init(movie: Movie,
                originalTitle: String? = nil,
                tagline: String? = nil,
                releaseDate: Date? = nil,
                country: String? = nil,
                language: String? = nil,
                languages: [String] = [],
                status: String? = nil,
                rating: Double? = nil,
                votes: Int? = nil,
                certification: String? = nil,
                trailerURL: URL? = nil,
                homepageURL: URL? = nil,
                afterCredits: Bool? = nil,
                duringCredits: Bool? = nil) {
        self.movie = movie
        self.originalTitle = originalTitle
        self.tagline = tagline
        self.releaseDate = releaseDate
        self.country = country
        self.language = language
        self.languages = languages
        self.status = status
        self.rating = rating
        self.votes = votes
        self.certification = certification
        self.trailerURL = trailerURL
        self.homepageURL = homepageURL
        self.afterCredits = afterCredits
        self.duringCredits = duringCredits
    }
}
