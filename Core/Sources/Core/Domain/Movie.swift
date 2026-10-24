import Foundation

public struct Movie: Identifiable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let year: Int?
    public let overview: String?
    public let runtime: Int?
    public let genres: [String]
    public let posterURL: URL?

    public init(id: Int,
                title: String,
                year: Int?,
                overview: String?,
                runtime: Int?,
                genres: [String],
                posterURL: URL? = nil) {
        self.id = id
        self.title = title
        self.year = year
        self.overview = overview
        self.runtime = runtime
        self.genres = genres
        self.posterURL = posterURL
    }
}
