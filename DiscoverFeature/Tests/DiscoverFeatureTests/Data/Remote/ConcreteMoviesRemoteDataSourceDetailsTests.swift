import Foundation
import Networking
import Testing
@testable import DiscoverFeature

struct ConcreteMoviesRemoteDataSourceDetailsTests {
    @Test
    func details_whenClientSendSucceeds_shouldSendSummaryRequestAndDecodeDetailDTO() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: try JSONFixture.load("movie-details"),
                                                         statusCode: 200, headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        let result = try await sut.details(id: 1111)

        let invocations = await client.invocations
        #expect(invocations.count == 1)
        #expect(invocations.first?.url.absoluteString == "https://api.trakt.tv/movies/1111?extended=full")
        #expect(invocations.first?.method == "GET")
        #expect(invocations.first?.queryItems == [])
        #expect(invocations.first?.body == nil)
        #expect(invocations.first?.headers == ["Content-Type": "application/json",
                                               "Accept": "application/json",
                                               "User-Agent": "moviesapp/1.0",
                                               "trakt-api-key": "foo.clientID",
                                               "trakt-api-version": "2"])
        #expect(result.ids.trakt == 1111)
        #expect(result.title == "foo.title")
        #expect(result.year == 2222)
        #expect(result.overview == "foo.overview")
        #expect(result.runtime == 3333)
        #expect(result.genres == ["foo.genre", "foo.other.genre"])
        #expect(result.images?.poster == ["images.example.com/foo.poster.webp"])
        #expect(result.originalTitle == "foo.original.title")
        #expect(result.tagline == "foo.tagline")
        #expect(result.released == "2024-03-01")
        #expect(result.country == "br")
        #expect(result.language == "pt")
        #expect(result.languages == ["pt", "en"])
        #expect(result.status == "released")
        #expect(result.rating == 8.5)
        #expect(result.votes == 4444)
        #expect(result.certification == "foo.certification")
        #expect(result.trailer == "https://example.com/foo.trailer")
        #expect(result.homepage == "https://example.com/foo.homepage")
        #expect(result.afterCredits == true)
        #expect(result.duringCredits == false)
    }

    @Test
    func details_whenOptionalFieldsAreMissing_shouldDecodeMinimalMovie() async throws {
        let body = Data(#"{"ids":{"trakt":1111},"title":"foo.title"}"#.utf8)
        let client = MockHTTPClient(result: HTTPResponse(body: body, statusCode: 200, headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        let result = try await sut.details(id: 1111)

        #expect(result.ids.trakt == 1111)
        #expect(result.title == "foo.title")
        #expect(result.year == nil)
        #expect(result.overview == nil)
        #expect(result.runtime == nil)
        #expect(result.genres == nil)
        #expect(result.images == nil)
        #expect(result.originalTitle == nil)
        #expect(result.tagline == nil)
        #expect(result.released == nil)
        #expect(result.country == nil)
        #expect(result.language == nil)
        #expect(result.languages == nil)
        #expect(result.status == nil)
        #expect(result.rating == nil)
        #expect(result.votes == nil)
        #expect(result.certification == nil)
        #expect(result.trailer == nil)
        #expect(result.homepage == nil)
        #expect(result.afterCredits == nil)
        #expect(result.duringCredits == nil)
    }

    @Test
    func details_whenOptionalFieldsAreNull_shouldDecodeWithoutDetails() async throws {
        let body = Data(#"{"ids":{"trakt":1111},"title":"foo.title","images":{"poster":null},"rating":null,"released":null,"after_credits":null,"trailer":null,"genres":null}"#.utf8)
        let client = MockHTTPClient(result: HTTPResponse(body: body, statusCode: 200, headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        let result = try await sut.details(id: 1111)

        #expect(result.images?.poster == nil)
        #expect(result.rating == nil)
        #expect(result.released == nil)
        #expect(result.afterCredits == nil)
        #expect(result.trailer == nil)
        #expect(result.genres == nil)
    }

    @Test
    func details_whenMoviePayloadIsInvalid_shouldThrowDecodingError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Data("[]".utf8), statusCode: 200, headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        do {
            _ = try await sut.details(id: 1111)
            Issue.record("Expected decoding error")
        } catch let error as MoviesRemoteDataSourceError {
            guard case .decoding = error else { Issue.record("Unexpected error: \(error)"); return }
            #expect(error.errorDescription == "O formato da resposta não corresponde ao contrato esperado.")
        }
    }

    @Test
    func details_whenClientSendThrowsHTTPError_shouldPropagateError() async throws {
        let client = MockHTTPClient(error: HTTPError.http(statusCode: 404, headers: [:]))
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        do {
            _ = try await sut.details(id: 1111)
            Issue.record("Expected HTTPError.http")
        } catch let error as HTTPError {
            guard case let .http(statusCode, headers) = error else { Issue.record("Unexpected error: \(error)"); return }
            #expect(statusCode == 404)
            #expect(headers == [:])
        }
        let invocations = await client.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func details_givenClientSendIsSuspended_whenTaskIsCancelled_shouldPropagateCancellationError() async throws {
        let client = MockHTTPClient(result: HTTPResponse(body: Data("{}".utf8), statusCode: 200, headers: [:]))
        await client.setNeedsToBeReleased()
        let sut = ConcreteMoviesRemoteDataSource(client: client, clientID: "foo.clientID")

        let task = Task { try await sut.details(id: 1111) }
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
