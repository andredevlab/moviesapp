@testable import Core

actor MockMoviesRemoteDataSource: MoviesRemoteDataSource {
    enum Invocation: Equatable, Sendable {
        case listPopular(filters: MovieFilters, page: PageRequest)
        case search(term: String, limit: Int)
    }

    enum Failure: Error {
        case unexpectedInvocation(Invocation)
    }

    private(set) var invocations: [Invocation] = []
    private var expectedInvocation: Invocation?
    private var listPopularResult: Result<Page<TraktMovieDTO>, any Error>?
    private var searchResult: Result<[TraktMovieDTO], any Error>?

    func define(result: Page<TraktMovieDTO>, for invocation: Invocation) {
        expectedInvocation = invocation
        listPopularResult = .success(result)
        searchResult = nil
    }

    func define(result: [TraktMovieDTO], for invocation: Invocation) {
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

    func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<TraktMovieDTO> {
        let invocation = Invocation.listPopular(filters: filters, page: page)
        invocations.append(invocation)
        guard invocation == expectedInvocation, let listPopularResult else {
            throw Failure.unexpectedInvocation(invocation)
        }
        return try listPopularResult.get()
    }

    func search(term: String, limit: Int) async throws -> [TraktMovieDTO] {
        let invocation = Invocation.search(term: term, limit: limit)
        invocations.append(invocation)
        guard invocation == expectedInvocation, let searchResult else {
            throw Failure.unexpectedInvocation(invocation)
        }
        return try searchResult.get()
    }
}
