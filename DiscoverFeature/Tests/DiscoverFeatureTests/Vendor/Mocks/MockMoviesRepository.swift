import Core

actor MockMoviesRepository: MoviesRepository {
    enum Invocation: Equatable, Sendable {
        case listPopular(filters: MovieFilters, page: PageRequest)
        case search(term: String, limit: Int)
    }

    enum Failure: Error {
        case unexpectedInvocation(Invocation)
    }

    private(set) var invocations: [Invocation] = []
    private var expectedInvocation: Invocation?
    private var listPopularResult: Result<Page<Movie>, any Error>?
    private var searchResult: Result<MovieSearchResults, any Error>?

    func define(result: Page<Movie>, for invocation: Invocation) {
        expectedInvocation = invocation
        listPopularResult = .success(result)
        searchResult = nil
    }

    func define(result: MovieSearchResults, for invocation: Invocation) {
        expectedInvocation = invocation
        listPopularResult = nil
        searchResult = .success(result)
    }

    func define(error: any Error, for invocation: Invocation) {
        expectedInvocation = invocation
        switch invocation {
        case .listPopular:
            listPopularResult = .failure(error)
            searchResult = nil
        case .search:
            listPopularResult = nil
            searchResult = .failure(error)
        }
    }

    func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie> {
        let invocation = Invocation.listPopular(filters: filters, page: page)
        invocations.append(invocation)
        guard invocation == expectedInvocation, let listPopularResult else {
            throw Failure.unexpectedInvocation(invocation)
        }
        return try listPopularResult.get()
    }

    func search(term: String, limit: Int) async throws -> MovieSearchResults {
        let invocation = Invocation.search(term: term, limit: limit)
        invocations.append(invocation)
        guard invocation == expectedInvocation, let searchResult else {
            throw Failure.unexpectedInvocation(invocation)
        }
        return try searchResult.get()
    }
}
