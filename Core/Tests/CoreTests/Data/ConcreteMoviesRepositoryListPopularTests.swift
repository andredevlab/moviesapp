import Testing
@testable import Core

struct ConcreteMoviesRepositoryListPopularTests {
    @Test
    func listPopular_whenRemoteDSSucceeds_shouldInvokeRemoteDSAndReturnMappedPageOfMovies() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let trackMovieDTO = Helper.makeTraktMovieDTO(traktID: 1111,
                                                     title: "foo.title",
                                                     year: 2222,
                                                     overview: "foo.overview",
                                                     runtime: 3333,
                                                     genres: ["foo.genre", "foo.other.genre"])
        let pagination = Helper.makePagination(page: 5555, limit: 6666, pageCount: 7777, itemCount: 8888)
        let filter = Helper.makeMovieFilters(year: 4444, genre: .action)
        let pageRequest = try Helper.makePageRequest(page: 5555, limit: 6666)
        
        await remoteDataSource.define(result: Helper.makePage(items: [trackMovieDTO], pagination: pagination),
                                      for: .listPopular(filters: filter, page: pageRequest))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.listPopular(filters: Helper.makeMovieFilters(year: 4444, genre: .action),
                                               page: Helper.makePageRequest(page: 5555, limit: 6666))
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        guard let first = invocations.first, case let .listPopular(invockedFilters, invockedPage) = first else {
            Issue.record("Expected listPopular invocation")
            return
        }
        
        #expect(invockedFilters.year == 4444)
        #expect(invockedFilters.genre == .action)
        #expect(invockedPage.page == 5555)
        #expect(invockedPage.limit == 6666)
        #expect(result.items.count == 1)
        #expect(result.items.first?.id == 1111)
        #expect(result.items.first?.title == "foo.title")
        #expect(result.items.first?.year == 2222)
        #expect(result.items.first?.overview == "foo.overview")
        #expect(result.items.first?.runtime == 3333)
        #expect(result.items.first?.genres == ["foo.genre", "foo.other.genre"])
        #expect(result.pagination.page == 5555)
        #expect(result.pagination.limit == 6666)
        #expect(result.pagination.pageCount == 7777)
        #expect(result.pagination.itemCount == 8888)
    }
    
    @Test
    func listPopular_whenFiltersAreNil_shouldInvokeRemoteDSWithNilFiltersAndReturnMappedPageOfMovies() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let trackMovieDTO = Helper.makeTraktMovieDTO(traktID: 1111, title: "foo.title")
        let pagination = Helper.makePagination(page: 2222, limit: 3333, pageCount: 4444, itemCount: 5555)
        let filter = Helper.makeMovieFilters(year: nil, genre: nil)
        let pageRequest = try Helper.makePageRequest(page: 2222, limit: 3333)
        
        await remoteDataSource.define(result: Helper.makePage(items: [trackMovieDTO], pagination: pagination),
                                      for: .listPopular(filters: filter, page: pageRequest))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let _ = try await sut.listPopular(filters: Helper.makeMovieFilters(year: nil, genre: nil),
                                          page: Helper.makePageRequest(page: 2222, limit: 3333))
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        guard let first = invocations.first, case let .listPopular(invockedFilters, invockedPage) = first else {
            Issue.record("Expected listPopular invocation")
            return
        }
        
        #expect(invockedFilters.year == nil)
        #expect(invockedFilters.genre == nil)
        #expect(invockedPage.page == 2222)
        #expect(invockedPage.limit == 3333)
    }
    
    @Test
    func listPopular_whenRemoteDSSucceedsWithEmptyMovies_shouldReturnEmptyPage() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let pagination = Helper.makePagination(page: 1111, limit: 2222, pageCount: 3333, itemCount: 4444)
        
        await remoteDataSource.define(result: Helper.makePage(items: [], pagination: pagination),
                                      for: .listPopular(filters: Helper.makeMovieFilters(),
                                                        page: try Helper.makePageRequest(page: 1111, limit: 2222)))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        let result = try await sut.listPopular(filters: Helper.makeMovieFilters(),
                                               page: Helper.makePageRequest(page: 1111, limit: 2222))
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
        
        #expect(result.items.isEmpty)
        #expect(result.pagination.page == 1111)
        #expect(result.pagination.limit == 2222)
        #expect(result.pagination.pageCount == 3333)
        #expect(result.pagination.itemCount == 4444)
    }
    
    @Test
    func listPopular_whenRemoteDSThrowsMoviesRemoteDSError_shouldPropagateError() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let pageRequest = try Helper.makePageRequest(page: 1111, limit: 2222)
        
        await remoteDataSource.define(error: MoviesRemoteDataSourceError.invalidPagination,
                                      for: .listPopular(filters: Helper.makeMovieFilters(),
                                                        page: pageRequest))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        do {
            _ = try await sut.listPopular(filters: Helper.makeMovieFilters(),
                                          page: Helper.makePageRequest(page: 1111, limit: 2222))
            Issue.record("Expected to throw")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidPagination = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Os headers de paginação estão ausentes ou inconsistentes.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func listPopular_whenRemoteDSThrowsCancellation_shouldPropagateCancellationError() async throws {
        let remoteDataSource = MockMoviesRemoteDataSource()
        let pageRequest = try Helper.makePageRequest(page: 1111, limit: 2222)
        
        await remoteDataSource.define(error: CancellationError(),
                                      for: .listPopular(filters: Helper.makeMovieFilters(),
                                                        page: pageRequest))
        
        let sut = ConcreteMoviesRepository(remoteDataSource: remoteDataSource)
        
        do {
            _ = try await sut.listPopular(filters: Helper.makeMovieFilters(),
                                          page: Helper.makePageRequest(page: 1111, limit: 2222))
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await remoteDataSource.invocations
        #expect(invocations.count == 1)
    }
    
}
