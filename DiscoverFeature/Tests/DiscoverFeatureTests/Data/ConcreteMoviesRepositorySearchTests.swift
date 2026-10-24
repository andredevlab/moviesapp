import Testing
import Core
@testable import DiscoverFeature

struct ConcreteMoviesRepositorySearchTests {
    @Test
    func search_whenRemoteDSSucceeds_shouldInvokeRemoteDSAndReturnMappedMovies() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let trackMovieDTO = Helper.makeTraktMovieDTO(traktID: 1111,
                                                     title: "foo.title",
                                                     year: 2222,
                                                     overview: "foo.overview",
                                                     runtime: 3333,
                                                     genres: ["foo.genre", "foo.other.genre"],
                                                     images: .init(poster: ["https://images.example.com/foo.search-poster.webp"]))
        
        await remoteDataSource.define(result: [trackMovieDTO],
                                      for: .search(term: "  foo.term  ", limit: 4444))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.search(term: "  foo.term  ", limit: 4444)
        
        let invocations = await remoteDataSource.invocations
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
        #expect(result.movies.first?.posterURL?.absoluteString == "https://images.example.com/foo.search-poster.webp")
    }
    
    @Test
    func search_whenRemoteDSSucceedsWithOptionalFieldsMissing_shouldPreserveNilAndMapGenresToEmpty() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let trackMovieDTO = Helper.makeTraktMovieDTO(traktID: 1111, title: "foo.title")
        
        await remoteDataSource.define(result: [trackMovieDTO],
                                      for: .search(term: "foo.term", limit: 2222))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.search(term: "foo.term", limit: 2222)
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        #expect(result.movies.count == 1)
        #expect(result.movies.first?.year == nil)
        #expect(result.movies.first?.overview == nil)
        #expect(result.movies.first?.runtime == nil)
        #expect(result.movies.first?.genres == [])
        #expect(result.movies.first?.posterURL == nil)
    }
    
    @Test
    func search_whenRemoteDSSucceedsWithEmptyMovies_shouldReturnEmptyResults() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        
        await remoteDataSource.define(result: [],
                                      for: .search(term: "foo.term", limit: 1111))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.search(term: "foo.term", limit: 1111)
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        #expect(result.movies.isEmpty)
        #expect(result.limit == 1111)
    }
    
    @Test
    func search_whenRemoteDSSucceedsWithMultipleMovies_shouldPreserveOrder() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let firstMovieDTO = Helper.makeTraktMovieDTO(traktID: 1111, title: "foo.first")
        let secondMovieDTO = Helper.makeTraktMovieDTO(traktID: 2222, title: "foo.second")
        
        await remoteDataSource.define(result: [firstMovieDTO, secondMovieDTO],
                                      for: .search(term: "foo.term", limit: 3333))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.search(term: "foo.term", limit: 3333)
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        #expect(result.movies.count == 2)
        #expect(result.movies.map(\.id) == [1111, 2222])
        #expect(result.movies.map(\.title) == ["foo.first", "foo.second"])
        #expect(result.limit == 3333)
    }
    
    @Test
    func search_whenRemoteDSThrowsMoviesRemoteDSError_shouldPropagateError() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        
        await remoteDataSource.define(error: MoviesRemoteDataSourceError.invalidSearchTerm,
                                      for: .search(term: "foo.term", limit: 1111))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 1111)
            Issue.record("Expected to throw")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidSearchTerm = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Informe um termo de busca não vazio.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func search_whenRemoteDSThrowsCancellation_shouldPropagateCancellationError() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        
        await remoteDataSource.define(error: CancellationError(),
                                      for: .search(term: "foo.term", limit: 1111))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 1111)
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
    }
}
