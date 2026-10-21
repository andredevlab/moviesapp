import Foundation

struct Movie: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let year: Int?
    let overview: String?
    let runtime: Int?
    let genres: [String]
}
