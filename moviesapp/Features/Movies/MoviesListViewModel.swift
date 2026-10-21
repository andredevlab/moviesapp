import Foundation
import Observation

@MainActor
protocol SearchDebouncing {
    func wait() async throws
}

struct SearchDebouncer: SearchDebouncing {
    func wait() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}

@MainActor
@Observable
final class MoviesListViewModel {
    enum Phase: Equatable {
        case idle, debouncing, loadingFirstPage, refreshing, paginating
    }

    struct State {
        var movies: [Movie] = []
        var page = 0
        var hasMore = true
        var hasLoaded = false
        var phase: Phase = .idle
        var errorMessage: String?
        var failedPage: Int?
        var failedPhase: Phase?
    }

    var searchText: String {
        didSet { scheduleQueryIfNeeded() }
    }
    var filters: MovieFilters {
        didSet { scheduleQueryIfNeeded() }
    }
    private(set) var state: State

    @ObservationIgnored private let service: any MoviesServicing
    @ObservationIgnored private let debouncer: any SearchDebouncing
    @ObservationIgnored private var activeQuery: MovieQuery
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var currentTask: Task<Void, Never>?

    static let pageLimit = 10

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(
        service: any MoviesServicing,
        debouncer: (any SearchDebouncing)? = nil,
        searchText: String = "",
        filters: MovieFilters? = nil,
        initialState: State? = nil
    ) {
        self.service = service
        self.debouncer = debouncer ?? SearchDebouncer()
        self.searchText = searchText
        let resolvedFilters = filters ?? MovieFilters()
        self.filters = resolvedFilters
        activeQuery = MovieQuery(term: searchText, filters: resolvedFilters)
        state = initialState ?? State()
    }

    func loadInitialIfNeeded() async {
        guard !state.hasLoaded, state.phase == .idle, state.errorMessage == nil else { return }
        await startLoad(page: 1, phase: .loadingFirstPage)
    }

    func loadMoreIfNeeded(currentMovieID: Movie.ID) async {
        guard !isSearching, currentMovieID == state.movies.last?.id,
              state.hasLoaded, state.hasMore, state.phase == .idle,
              state.errorMessage == nil else { return }
        await startLoad(page: state.page + 1, phase: .paginating)
    }

    func refresh() async {
        // Invalidate append/debounce before starting the replacement request.
        let query = MovieQuery(term: searchText, filters: filters)
        if query != activeQuery { state = State() }
        activeQuery = query
        await startLoad(page: 1, phase: .refreshing)
    }

    func retry() async {
        guard state.phase == .idle, let page = state.failedPage else { return }
        await startLoad(page: page, phase: state.failedPhase ?? .loadingFirstPage)
    }

    /// Synchronization point for a scheduled search, also used by focused unit tests.
    func waitForPendingSearch() async {
        await currentTask?.value
    }

    private func scheduleQueryIfNeeded() {
        let query = MovieQuery(term: searchText, filters: filters)
        guard query != activeQuery else { return }
        let requestGeneration = invalidateCurrentRequest()
        activeQuery = query
        state = State(phase: .debouncing)
        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await debouncer.wait()
                try Task.checkCancellation()
                guard generation == requestGeneration else { return }
                await performLoad(page: 1, phase: .loadingFirstPage, query: query, generation: requestGeneration)
            } catch {
                guard generation == requestGeneration else { return }
                state.phase = .idle
                currentTask = nil
            }
        }
    }

    private func startLoad(page: Int, phase: Phase) async {
        let requestGeneration = invalidateCurrentRequest()
        let query = activeQuery
        state.phase = phase
        state.errorMessage = nil
        currentTask = Task { [weak self] in
            guard let self else { return }
            await performLoad(page: page, phase: phase, query: query, generation: requestGeneration)
        }
        await currentTask?.value
    }

    private func performLoad(page: Int, phase: Phase, query: MovieQuery, generation requestGeneration: UUID) async {
        guard generation == requestGeneration else { return }
        state.phase = phase
        state.errorMessage = nil
        do {
            let result = try await service.fetchMovies(query: query, page: page, limit: Self.pageLimit)
            try Task.checkCancellation()
            guard generation == requestGeneration else { return }

            var ids = Set(page == 1 ? [] : state.movies.map(\.id))
            let uniqueMovies = result.movies.filter { ids.insert($0.id).inserted }
            state.movies = page == 1 ? uniqueMovies : state.movies + uniqueMovies
            state.page = result.pagination.page
            state.hasMore = query.term.isEmpty && result.pagination.hasNextPage
            state.hasLoaded = true
            state.failedPage = nil
            state.failedPhase = nil
        } catch {
            guard generation == requestGeneration else { return }
            if !(error is CancellationError), (error as? URLError)?.code != .cancelled, !Task.isCancelled {
                state.errorMessage = error.localizedDescription
                state.failedPage = page
                state.failedPhase = phase
            }
        }
        guard generation == requestGeneration else { return }
        state.phase = .idle
        currentTask = nil
    }

    @discardableResult
    private func invalidateCurrentRequest() -> UUID {
        currentTask?.cancel()
        currentTask = nil
        generation = UUID()
        return generation
    }
}
