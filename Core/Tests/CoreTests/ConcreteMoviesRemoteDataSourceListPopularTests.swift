import Foundation
import Networking
import Testing
@testable import Core

struct ConcreteMoviesRemoteDataSourceListPopularTests {
    @Test
    func listPopular_whenClientSendSucceeds_shouldSendExpectedRequestAndReturnDecodedPage() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: try JSONFixture.load("popular-movies"),
                                                         statusCode: 200,
                                                         headers: ["X-Pagination-Page": "4444",
                                                                   "X-Pagination-Limit": "5555",
                                                                   "X-Pagination-Page-Count": "6666",
                                                                   "X-Pagination-Item-Count": "7777"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        let result = try await sut.listPopular(filters: MovieFilters(year: 2222, genre: .scienceFiction),
                                               page: PageRequest(page: 4444, limit: 5555))
        
        let invocations = await client.invocations
        #expect(invocations.count == 1)
        #expect(invocations.first?.url.absoluteString == "https://api.trakt.tv/movies/popular?page=4444&limit=5555&extended=full&years=2222&genres=science-fiction")
        #expect(invocations.first?.method == "GET")
        #expect(invocations.first?.queryItems == [])
        #expect(invocations.first?.headers == ["Content-Type": "application/json",
                                               "Accept": "application/json",
                                               "User-Agent": "moviesapp/1.0",
                                               "trakt-api-key": "foo.clientID",
                                               "trakt-api-version": "2"])
        #expect(invocations.first?.body == nil)
        #expect(result.items.count == 1)
        #expect(result.items.first?.ids.trakt == 1111)
        #expect(result.items.first?.title == "foo.title")
        #expect(result.items.first?.year == 2222)
        #expect(result.items.first?.overview == "foo.overview")
        #expect(result.items.first?.runtime == 3333)
        #expect(result.items.first?.genres == ["foo.genre"])
        #expect(result.pagination.page == 4444)
        #expect(result.pagination.limit == 5555)
        #expect(result.pagination.pageCount == 6666)
        #expect(result.pagination.itemCount == 7777)
    }
    
    @Test
    func listPopular_givenEmptyFilters_whenCreatingRequest_shouldOmitFilterParameters() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1111",
                                                                   "x-pagination-limit": "2222",
                                                                   "x-pagination-page-count": "3333",
                                                                   "x-pagination-item-count": "4444"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
        
        let invocations = await client.invocations
        #expect(invocations.count == 1)
        #expect(invocations.first?.url.absoluteString == "https://api.trakt.tv/movies/popular?page=1111&limit=2222&extended=full")
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenMoviesAreEmpty_shouldReturnEmptyPage() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1",
                                                                   "x-pagination-limit": "1111",
                                                                   "x-pagination-page-count": "0",
                                                                   "x-pagination-item-count": "0"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        let result = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1, limit: 1111))
        
        #expect(result.items.isEmpty)
        #expect(result.pagination.pageCount == 0)
        #expect(result.pagination.itemCount == 0)
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenBodyIsInvalid_shouldThrowDecodingError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("foo.invalid.json".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1111",
                                                                   "x-pagination-limit": "2222",
                                                                   "x-pagination-page-count": "3333",
                                                                   "x-pagination-item-count": "4444"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected MoviesRemoteDataSourceError.decoding")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .decoding = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "O formato da resposta não corresponde ao contrato esperado.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenPaginationHeadersAreMissing_shouldThrowInvalidPagination() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected MoviesRemoteDataSourceError.invalidPagination")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidPagination = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Os headers de paginação estão ausentes ou inconsistentes.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenPageDiffersFromRequested_shouldThrowInvalidPagination() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "2222",
                                                                   "x-pagination-limit": "3333",
                                                                   "x-pagination-page-count": "4444",
                                                                   "x-pagination-item-count": "5555"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 3333))
            Issue.record("Expected MoviesRemoteDataSourceError.invalidPagination")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidPagination = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Os headers de paginação estão ausentes ou inconsistentes.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenPaginationHeaderIsNotAnInteger_shouldThrowInvalidPagination() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "foo.page",
                                                                   "x-pagination-limit": "1111",
                                                                   "x-pagination-page-count": "2222",
                                                                   "x-pagination-item-count": "3333"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 4444, limit: 1111))
            Issue.record("Expected MoviesRemoteDataSourceError.invalidPagination")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidPagination = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Os headers de paginação estão ausentes ou inconsistentes.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenPageCountIsNegative_shouldThrowInvalidPagination() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1111",
                                                                   "x-pagination-limit": "2222",
                                                                   "x-pagination-page-count": "-1",
                                                                   "x-pagination-item-count": "4444"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected MoviesRemoteDataSourceError.invalidPagination")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidPagination = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Os headers de paginação estão ausentes ou inconsistentes.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenLimitDiffersFromRequested_shouldThrowUnexpectedPageSize() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1111",
                                                                   "x-pagination-limit": "3333",
                                                                   "x-pagination-page-count": "4444",
                                                                   "x-pagination-item-count": "5555"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected MoviesRemoteDataSourceError.unexpectedPageSize")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .unexpectedPageSize(let requested, let effective, let received) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(requested == 2222)
            #expect(effective == 3333)
            #expect(received == 0)
            #expect(error.errorDescription == "Limite solicitado: 2222; efetivo: 3333; recebidos: 0. A resposta não atende ao limite solicitado.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_givenClientSendResponse_whenMovieCountExceedsRequestedLimit_shouldThrowUnexpectedPageSize() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: try JSONFixture.load("popular-movies-over-limit"),
                                                         statusCode: 200,
                                                         headers: ["x-pagination-page": "1",
                                                                   "x-pagination-limit": "1",
                                                                   "x-pagination-page-count": "3333",
                                                                   "x-pagination-item-count": "3333"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1, limit: 1))
            Issue.record("Expected MoviesRemoteDataSourceError.unexpectedPageSize")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .unexpectedPageSize(let requested, let effective, let received) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(requested == 1)
            #expect(effective == 1)
            #expect(received == 2)
            #expect(error.errorDescription == "Limite solicitado: 1; efetivo: 1; recebidos: 2. A resposta não atende ao limite solicitado.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test
    func listPopular_whenClientSendThrowsHTTPError_shouldPropagateError() async throws {
        let client = MockHTTPClient(error: HTTPError.http(statusCode: 429, headers: ["retry-after": "1111"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 2222, limit: 3333))
            Issue.record("Expected HTTPError.http")
        } catch let error as HTTPError {
            guard case .http(let statusCode, let headers) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(statusCode == 429)
            #expect(headers == ["retry-after": "1111"])
            #expect(error.errorDescription == "O servidor retornou HTTP 429.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func listPopular_whenClientSendThrowsCancellation_shouldPropagateCancellationError() async throws {
        let client = MockHTTPClient(error: CancellationError())
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func listPopular_givenClientSendIsSuspended_whenTaskIsCancelled_shouldPropagateCancellationError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("foo.invalid.json".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        await client.setNeedsToBeReleased()
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        let task = Task {
            try await sut.listPopular(filters: MovieFilters(), page: PageRequest(page: 1111, limit: 2222))
        }
        await client.waitUntilCalled()
        task.cancel()
        
        do {
            _ = try await task.value
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
}
