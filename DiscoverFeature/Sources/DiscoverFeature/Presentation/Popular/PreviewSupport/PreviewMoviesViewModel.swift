#if DEBUG
import Observation
import Core

@MainActor
@Observable
final class PreviewMoviesViewModel: MoviesListViewModel {
    var searchText: String
    var filters: MovieFilters
    var state: MoviesListState

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(movies: [Movie] = DiscoverPreviewData.movies,
         searchText: String = "",
         filters: MovieFilters = MovieFilters(),
         phase: MoviesListPhase = .idle,
         errorMessage: String? = nil,
         hasLoaded: Bool = true,
         hasMore: Bool = true) {
        self.searchText = searchText
        self.filters = filters
        state = MoviesListState(movies: movies,
                                page: hasLoaded ? 1 : 0,
                                hasMore: hasMore,
                                hasLoaded: hasLoaded,
                                phase: phase,
                                errorMessage: errorMessage)
    }

    // Keep each preview in its chosen state without requesting live data.
    func load() async {}
    func search(term: String) async {}
    func paginate(currentMovieID: Movie.ID) async {}
    func refresh() async {}
    func retry() async {}
}
#endif
