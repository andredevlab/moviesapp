import Observation
import Core

enum MoviesListPhase: Equatable {
    case idle, debouncing, loadingFirstPage, refreshing, paginating
}

struct MoviesListState {
    var movies: [Movie] = []
    var page = 0
    var hasMore = true
    var hasLoaded = false
    var phase: MoviesListPhase = .idle
    var errorMessage: String?
    var failedPage: Int?
    var failedPhase: MoviesListPhase?
}

@MainActor
protocol MoviesListViewModel: AnyObject, Observable {
    var searchText: String { get set }
    var filters: MovieFilters { get set }
    var state: MoviesListState { get }
    var isSearching: Bool { get }

    func load() async
    func search(term: String) async
    func paginate(currentMovieID: Movie.ID) async
    func refresh() async
    func retry() async
}
