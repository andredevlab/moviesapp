import Foundation
import Observation
import Core
import FactoryKit

@MainActor
@Observable
final class ConcreteMoviesListViewModel: MoviesListViewModel {
    var searchText: String
    var filters: MovieFilters
    private(set) var state: MoviesListState
    
    @ObservationIgnored @Injected(\.listPopularMoviesUseCase) private var listPopularMoviesUseCase
    @ObservationIgnored @Injected(\.searchMoviesUseCase) private var searchMoviesUseCase
    
    @ObservationIgnored private var activeQuery: MovieQuery
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var currentTask: Task<Void, Never>?
    
    private let pageLimit = 10
    
    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    init(searchText: String = "",
         filters: MovieFilters? = nil,
         initialState: MoviesListState? = nil) {
        self.searchText = searchText
        let resolvedFilters = filters ?? MovieFilters()
        self.filters = resolvedFilters
        activeQuery = MovieQuery(term: searchText, filters: resolvedFilters)
        state = initialState ?? MoviesListState()
    }
    
    func load() async {
        guard !Task.isCancelled else { return }

        let query = MovieQuery(filters: filters)
        if isSearching { searchText = "" }

        let needsInitialLoad = !state.hasLoaded && state.errorMessage == nil &&
            (state.phase == .idle || currentTask?.isCancelled == true)
        guard query != activeQuery || needsInitialLoad else { return }

        if query != activeQuery { state = MoviesListState() }
        activeQuery = query
        await listPopularMovies(page: 1, phase: .loadingFirstPage)
    }

    func search(term: String) async {
        guard !Task.isCancelled else { return }

        let query = MovieQuery(term: term, filters: filters)
        guard !query.term.isEmpty else { return }
        searchText = term

        let needsInitialLoad = !state.hasLoaded && state.errorMessage == nil &&
            (state.phase == .idle || currentTask?.isCancelled == true)
        guard query != activeQuery || needsInitialLoad else { return }

        if query != activeQuery { state = MoviesListState() }
        activeQuery = query
        await searchMovies(term: query.term, phase: .debouncing)
    }

    func paginate(currentMovieID: Movie.ID) async {
        guard !Task.isCancelled,
              !isSearching,
              currentMovieID == state.movies.last?.id,
              state.hasLoaded,
              state.hasMore,
              state.phase == .idle,
              state.errorMessage == nil else { return }
        
        await listPopularMovies(page: state.page + 1, phase: .paginating)
    }
    
    func refresh() async {
        guard !Task.isCancelled else { return }

        let query = MovieQuery(term: searchText, filters: filters)
        
        /// Invalidate append/debounce before starting the replacement request.
        if query != activeQuery {
            state = MoviesListState()
        }
        
        activeQuery = query

        if isSearching {
            await searchMovies(term: query.term, phase: .refreshing)
        } else {
            await listPopularMovies(page: 1, phase: .refreshing)
        }
    }
    
    func retry() async {
        guard !Task.isCancelled,
              state.phase == .idle,
              let page = state.failedPage else { return }

        let phase = state.failedPhase ?? .loadingFirstPage
        if activeQuery.term.isEmpty {
            await listPopularMovies(page: page, phase: phase)
        } else {
            await searchMovies(term: activeQuery.term, phase: phase)
        }
    }

    private func listPopularMovies(page: Int, phase: MoviesListPhase) async {
        let requestGeneration = invalidateCurrentRequest()
        let filters = activeQuery.filters
        state.phase = phase
        state.errorMessage = nil

        let task = Task {
            do {
                let result = try await listPopularMoviesUseCase.execute(filters: filters,
                                                                       page: PageRequest(page: page,
                                                                                         limit: pageLimit))

                try Task.checkCancellation()
                guard generation == requestGeneration else { return }

                var ids = Set(page == 1 ? [] : state.movies.map(\.id))
                let uniqueMovies = result.items.filter { ids.insert($0.id).inserted }
                state.movies = page == 1 ? uniqueMovies : state.movies + uniqueMovies
                state.page = result.pagination.page
                state.hasMore = result.pagination.hasNextPage
                state.hasLoaded = true
                state.failedPage = nil
                state.failedPhase = nil
            } catch {
                guard generation == requestGeneration else { return }
                recordFailure(error, page: page, phase: phase)
            }

            guard generation == requestGeneration else { return }
            state.phase = .idle
            currentTask = nil
        }

        currentTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private func searchMovies(term: String, phase: MoviesListPhase) async {
        let requestGeneration = invalidateCurrentRequest()
        let requestPhase: MoviesListPhase = phase == .debouncing ? .loadingFirstPage : phase
        state.phase = phase
        state.errorMessage = nil

        let task = Task {
            do {
                if phase == .debouncing {
                    try await Task.sleep(for: .milliseconds(300))
                    try Task.checkCancellation()
                    guard generation == requestGeneration else { return }
                    state.phase = requestPhase
                }

                let result = try await searchMoviesUseCase.execute(term: term,
                                                                  limit: pageLimit)

                try Task.checkCancellation()
                guard generation == requestGeneration else { return }

                var ids = Set<Movie.ID>()
                state.movies = result.movies.filter { ids.insert($0.id).inserted }
                state.page = 1
                state.hasMore = false
                state.hasLoaded = true
                state.failedPage = nil
                state.failedPhase = nil
            } catch {
                guard generation == requestGeneration else { return }
                recordFailure(error, page: 1, phase: requestPhase)
            }

            guard generation == requestGeneration else { return }
            state.phase = .idle
            currentTask = nil
        }

        currentTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private func recordFailure(_ error: any Error, page: Int, phase: MoviesListPhase) {
        guard !(error is CancellationError),
              (error as? URLError)?.code != .cancelled,
              !Task.isCancelled else { return }

        state.errorMessage = error.localizedDescription
        state.failedPage = page
        state.failedPhase = phase
    }
    
    @discardableResult
    private func invalidateCurrentRequest() -> UUID {
        currentTask?.cancel()
        currentTask = nil
        generation = UUID()
        return generation
    }
}
