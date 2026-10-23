import Foundation
import Core

struct MovieQuery: Equatable, Hashable, Sendable {
    let term: String
    let filters: MovieFilters

    init(term: String = "", filters: MovieFilters = MovieFilters()) {
        self.term = term.trimmingCharacters(in: .whitespacesAndNewlines)
        self.filters = self.term.isEmpty ? filters : MovieFilters()
    }
}
