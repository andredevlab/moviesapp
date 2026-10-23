import Foundation
import Networking
import Testing
@testable import Core

struct ConcreteMoviesRemoteDataSourceSearchTests {
    @Test
    func search_whenClientSendSucceeds_shouldSendFirstPageAndReturnDecodedMovies() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: try JSONFixture.load("search-movies"),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        let result = try await sut.search(term: "  foo+term  ", limit: 2222)
        
        let invocations = await client.invocations
        #expect(invocations.count == 1)
        #expect(invocations.first?.url.absoluteString == "https://api.trakt.tv/search/movie?page=1&limit=2222&extended=full&query=foo%2Bterm")
        #expect(invocations.first?.method == "GET")
        #expect(invocations.first?.queryItems == [])
        #expect(invocations.first?.headers == ["Content-Type": "application/json",
                                               "Accept": "application/json",
                                               "User-Agent": "moviesapp/1.0",
                                               "trakt-api-key": "foo.clientID",
                                               "trakt-api-version": "2"])
        #expect(invocations.first?.body == nil)
        #expect(result.count == 1)
        #expect(result.first?.ids.trakt == 1111)
        #expect(result.first?.title == "foo.title")
        #expect(result.first?.year == nil)
        #expect(result.first?.overview == nil)
        #expect(result.first?.runtime == nil)
        #expect(result.first?.genres == ["foo.genre"])
    }
    
    @Test
    func search_givenEmptyTerm_whenValidatingTerm_shouldThrowInvalidSearchTerm() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "", limit: 1111)
            Issue.record("Expected MoviesRemoteDataSourceError.invalidSearchTerm")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidSearchTerm = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Informe um termo de busca não vazio.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 0)
    }
    
    @Test
    func search_givenWhitespaceTerm_whenValidatingTerm_shouldThrowInvalidSearchTerm() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "   ", limit: 1111)
            Issue.record("Expected MoviesRemoteDataSourceError.invalidSearchTerm")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidSearchTerm = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "Informe um termo de busca não vazio.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 0)
    }
    
    @Test
    func search_givenZeroLimit_whenValidatingLimit_shouldThrowInvalidLimit() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 0)
            Issue.record("Expected MoviesRemoteDataSourceError.invalidLimit")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidLimit = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "O limite deve ser maior que zero.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 0)
    }
    
    @Test
    func search_givenNegativeLimit_whenValidatingLimit_shouldThrowInvalidLimit() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "foo.term", limit: -1)
            Issue.record("Expected MoviesRemoteDataSourceError.invalidLimit")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .invalidLimit = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(error.errorDescription == "O limite deve ser maior que zero.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 0)
    }
    
    @Test
    func search_givenClientSendResponse_whenMovieEnvelopeIsInvalid_shouldThrowDecodingError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data(#"[{"title":"foo.title"}]"#.utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 1111)
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
    func search_givenClientSendResponse_whenMoviesAreEmpty_shouldReturnEmptyMovies() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        let result = try await sut.search(term: "foo.term", limit: 1111)
        
        #expect(result.isEmpty)
    }
    
    @Test
    func search_whenClientSendThrowsHTTPError_shouldPropagateError() async throws {
        let client = MockHTTPClient(error: HTTPError.http(statusCode: 429, headers: ["retry-after": "2222"]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 1111)
            Issue.record("Expected HTTPError.http")
        } catch let error as HTTPError {
            guard case .http(let statusCode, let headers) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(statusCode == 429)
            #expect(headers == ["retry-after": "2222"])
            #expect(error.errorDescription == "O servidor retornou HTTP 429.")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func search_whenClientSendThrowsCancellation_shouldPropagateCancellationError() async throws {
        let client = MockHTTPClient(error: CancellationError())
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        
        do {
            _ = try await sut.search(term: "foo.term", limit: 1111)
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
    @Test
    func search_givenClientSendIsSuspended_whenTaskIsCancelled_shouldPropagateCancellationError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("foo.invalid.json".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        await client.setNeedsToBeReleased()
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        let task = Task {
            try await sut.search(term: "foo.term", limit: 1111)
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
    
    @Test
    func search_givenClientSendIsSuspended_whenClientIsReleased_shouldReturnDecodedMovies() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Foundation.Data("[]".utf8),
                                                         statusCode: 200,
                                                         headers: [:]))
        await client.setNeedsToBeReleased()
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")
        let task = Task {
            try await sut.search(term: "foo.term", limit: 1111)
        }
        await client.waitUntilCalled()
        await client.release()
        
        let result = try await task.value
        
        #expect(result.isEmpty)
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }
    
}
