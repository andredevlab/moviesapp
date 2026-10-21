import Foundation

struct MovieFilters: Equatable, Hashable, Sendable {
    var year: Int?
    var genre: MovieGenre?

    var isEmpty: Bool { year == nil && genre == nil }
}

enum MovieGenre: String, CaseIterable, Identifiable, Hashable, Sendable {
    case action, adventure, comedy, drama, horror
    case scienceFiction = "science-fiction"
    case thriller

    var id: String { rawValue }

    var title: String {
        switch self {
        case .action: "Ação"
        case .adventure: "Aventura"
        case .comedy: "Comédia"
        case .drama: "Drama"
        case .horror: "Terror"
        case .scienceFiction: "Ficção científica"
        case .thriller: "Suspense"
        }
    }
}

struct MovieQuery: Equatable, Hashable, Sendable {
    let term: String
    let filters: MovieFilters

    init(term: String = "", filters: MovieFilters = MovieFilters()) {
        self.term = term.trimmingCharacters(in: .whitespacesAndNewlines)
        self.filters = self.term.isEmpty ? filters : MovieFilters()
    }
}
