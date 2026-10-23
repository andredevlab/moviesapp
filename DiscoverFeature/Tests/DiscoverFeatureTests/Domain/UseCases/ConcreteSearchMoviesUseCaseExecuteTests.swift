import Foundation
import Testing
import Core
@testable import DiscoverFeature

struct ConcreteSearchMoviesUseCaseExecuteTests {
    @Test
    func execute_whenRepositorySucceeds_shouldReturnExpectedMovieSearchResults() async throws {
        let repository = MockMoviesRepository()
        let movie = Helper.makeMovie(id: 1111,
                                     title: "foo.title",
                                     year: 2222,
                                     overview: "foo.overview",
                                     runtime: 3333,
                                     genres: ["foo.genre", "foo.other.genre"])
        
        await repository.define(result: MovieSearchResults(movies: [movie], limit: 4444),
                                for: .search(term: "  foo.term  ", limit: 4444))
        
        let sut = ConcreteSearchMoviesUseCase(repository: repository)
        
        let result = try await sut.execute(term: "  foo.term  ", limit: 4444)
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
        
        guard let first = invocations.first, case let .search(invokedTerm, invokedLimit) = first else {
            Issue.record("Expected search invocation")
            return
        }
        
        #expect(invokedTerm == "  foo.term  ")
        #expect(invokedLimit == 4444)
        #expect(result.limit == 4444)
        #expect(result.movies.count == 1)
        #expect(result.movies.first?.id == 1111)
        #expect(result.movies.first?.title == "foo.title")
        #expect(result.movies.first?.year == 2222)
        #expect(result.movies.first?.overview == "foo.overview")
        #expect(result.movies.first?.runtime == 3333)
        #expect(result.movies.first?.genres == ["foo.genre", "foo.other.genre"])
    }
    
    @Test
    func execute_whenRepositoryThrowsAnyError_shouldPropagateError() async throws {
        let repository = MockMoviesRepository()
        
        await repository.define(error: NSError(domain: "foo.error",
                                               code: 2222,
                                               userInfo: [NSLocalizedDescriptionKey: "foo.description"]),
                                for: .search(term: "foo.term", limit: 1111))
        
        let sut = ConcreteSearchMoviesUseCase(repository: repository)
        
        do {
            _ = try await sut.execute(term: "foo.term", limit: 1111)
            Issue.record("Expected Error")
        } catch {
            let error = error as NSError
            #expect(error.domain == "foo.error")
            #expect(error.code == 2222)
            #expect(error.localizedDescription == "foo.description")
        }
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func execute_whenRepositoryThrowsCancellation_shouldPropagateError() async throws {
        let repository = MockMoviesRepository()
        
        await repository.define(error: CancellationError(),
                                for: .search(term: "foo.term", limit: 1111))
        
        let sut = ConcreteSearchMoviesUseCase(repository: repository)
        
        do {
            _ = try await sut.execute(term: "foo.term", limit: 1111)
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
    }
}
