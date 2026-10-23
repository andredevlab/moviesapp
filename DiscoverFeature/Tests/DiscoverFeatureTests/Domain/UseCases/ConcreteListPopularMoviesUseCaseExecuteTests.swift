import Foundation
import Testing
import Core
@testable import DiscoverFeature

struct ConcreteListPopularMoviesUseCaseExecuteTests {
    @Test
    func execute_whenRepositorySucceeds_shouldReturnExpectedPage() async throws {
        let repository = MockMoviesRepository()
        let movie = Helper.makeMovie(id: 1111,
                                     title: "foo.title",
                                     year: 2222,
                                     overview: "foo.overview",
                                     runtime: 3333,
                                     genres: ["foo.genre", "foo.other.genre"])
        let filters = MovieFilters(year: 4444, genre: .action)
        let page = try PageRequest(page: 5555, limit: 6666)
        let pagination = Helper.makePagination(page: 5555, limit: 6666, pageCount: 7777, itemCount: 8888)
        
        await repository.define(result: Helper.makePage(items: [movie], pagination: pagination),
                                for: .listPopular(filters: filters, page: page))
        
        let sut = ConcreteListPopularMoviesUseCase(repository: repository)
        
        let result = try await sut.execute(filters: MovieFilters(year: 4444, genre: .action),
                                           page: PageRequest(page: 5555, limit: 6666))
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
        
        guard let first = invocations.first, case let .listPopular(invokedFilters, invokedPage) = first else {
            Issue.record("Expected listPopular invocation")
            return
        }
        
        #expect(invokedFilters.year == 4444)
        #expect(invokedFilters.genre == .action)
        #expect(invokedPage.page == 5555)
        #expect(invokedPage.limit == 6666)
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
    func execute_whenRepositoryThrowsAnyError_shouldPropagateError() async throws {
        let repository = MockMoviesRepository()
        let page = try PageRequest(page: 1111, limit: 2222)
        
        await repository.define(error: NSError(domain: "foo.error",
                                               code: 3333,
                                               userInfo: [NSLocalizedDescriptionKey: "foo.description"]),
                                for: .listPopular(filters: MovieFilters(), page: page))
        
        let sut = ConcreteListPopularMoviesUseCase(repository: repository)
        
        do {
            _ = try await sut.execute(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected Error")
        } catch {
            let error = error as NSError
            #expect(error.domain == "foo.error")
            #expect(error.code == 3333)
            #expect(error.localizedDescription == "foo.description")
        }
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func execute_whenRepositoryThrowsCancellation_shouldPropagateError() async throws {
        let repository = MockMoviesRepository()
        let page = try PageRequest(page: 1111, limit: 2222)
        
        await repository.define(error: CancellationError(),
                                for: .listPopular(filters: MovieFilters(), page: page))
        
        let sut = ConcreteListPopularMoviesUseCase(repository: repository)
        
        do {
            _ = try await sut.execute(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
    }
}
