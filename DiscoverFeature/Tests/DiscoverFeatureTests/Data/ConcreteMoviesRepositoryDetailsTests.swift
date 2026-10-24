import Foundation
import Testing
@testable import DiscoverFeature

struct ConcreteMoviesRepositoryDetailsTests {
    @Test
    func details_whenRemoteDSSucceeds_shouldInvokeRemoteDSAndReturnMappedMovieDetails() async throws {
        let remote = MockMoviesRemoteDataSource()
        let dto = Helper.makeTraktMovieDetailDTO(
            traktID: 1111, title: "foo.title", year: 2222, overview: "foo.overview", runtime: 3333,
            genres: ["foo.genre", "foo.other.genre"],
            images: .init(poster: ["images.example.com/foo.poster.webp"]),
            originalTitle: "foo.original.title", tagline: "foo.tagline", released: "2024-03-01",
            country: "br", language: "pt", languages: ["pt", "en"], status: "released",
            rating: 8.5, votes: 4444, certification: "foo.certification",
            trailer: "https://example.com/foo.trailer", homepage: "https://example.com/foo.homepage",
            afterCredits: true, duringCredits: false
        )
        await remote.define(result: dto, for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        let result = try await sut.details(id: 1111)

        let invocations = await remote.invocations
        #expect(invocations.count == 1)
        guard let first = invocations.first, case let .details(invokedID) = first else {
            Issue.record("Expected details invocation"); return
        }
        #expect(invokedID == 1111)
        #expect(result.movie.id == 1111)
        #expect(result.movie.title == "foo.title")
        #expect(result.movie.year == 2222)
        #expect(result.movie.overview == "foo.overview")
        #expect(result.movie.runtime == 3333)
        #expect(result.movie.genres == ["foo.genre", "foo.other.genre"])
        #expect(result.movie.posterURL?.absoluteString == "https://images.example.com/foo.poster.webp")
        #expect(result.originalTitle == "foo.original.title")
        #expect(result.tagline == "foo.tagline")
        #expect(result.releaseDate?.timeIntervalSince1970 == 1_709_251_200)
        #expect(result.country == "br")
        #expect(result.language == "pt")
        #expect(result.languages == ["pt", "en"])
        #expect(result.status == "released")
        #expect(result.rating == 8.5)
        #expect(result.votes == 4444)
        #expect(result.certification == "foo.certification")
        #expect(result.trailerURL?.absoluteString == "https://example.com/foo.trailer")
        #expect(result.homepageURL?.absoluteString == "https://example.com/foo.homepage")
        #expect(result.afterCredits == true)
        #expect(result.duringCredits == false)
    }

    @Test
    func details_whenOptionalFieldsAreMissing_shouldPreserveNilAndEmptyCollections() async throws {
        let remote = MockMoviesRemoteDataSource()
        let dto = Helper.makeTraktMovieDetailDTO(traktID: 1111, title: "foo.title")
        await remote.define(result: dto, for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        let result = try await sut.details(id: 1111)

        #expect(result.movie.year == nil)
        #expect(result.movie.overview == nil)
        #expect(result.movie.runtime == nil)
        #expect(result.movie.genres == [])
        #expect(result.movie.posterURL == nil)
        #expect(result.originalTitle == nil)
        #expect(result.tagline == nil)
        #expect(result.releaseDate == nil)
        #expect(result.country == nil)
        #expect(result.language == nil)
        #expect(result.languages == [])
        #expect(result.status == nil)
        #expect(result.rating == nil)
        #expect(result.votes == nil)
        #expect(result.certification == nil)
        #expect(result.trailerURL == nil)
        #expect(result.homepageURL == nil)
        #expect(result.afterCredits == nil)
        #expect(result.duringCredits == nil)
    }

    @Test
    func details_whenPosterIncludesHTTPS_shouldPreservePosterURL() async throws {
        let remote = MockMoviesRemoteDataSource()
        let dto = Helper.makeTraktMovieDetailDTO(images: .init(poster: ["https://images.example.com/foo.poster.webp"]))
        await remote.define(result: dto, for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        let result = try await sut.details(id: 1111)

        #expect(result.movie.posterURL?.absoluteString == "https://images.example.com/foo.poster.webp")
    }

    @Test
    func details_whenDateIsInvalidAndLinksAreEmpty_shouldKeepOptionalValuesAbsent() async throws {
        let remote = MockMoviesRemoteDataSource()
        let dto = Helper.makeTraktMovieDetailDTO(images: .init(poster: []), released: "foo.invalid.date",
                                                trailer: "", homepage: "")
        await remote.define(result: dto, for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        let result = try await sut.details(id: 1111)

        #expect(result.releaseDate == nil)
        #expect(result.movie.posterURL == nil)
        #expect(result.trailerURL == nil)
        #expect(result.homepageURL == nil)
    }

    @Test
    func details_whenRemoteDSThrowsAnyError_shouldPropagateError() async throws {
        let remote = MockMoviesRemoteDataSource()
        await remote.define(error: NSError(domain: "foo.error", code: 2222,
                                            userInfo: [NSLocalizedDescriptionKey: "foo.description"]),
                            for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        do {
            _ = try await sut.details(id: 1111)
            Issue.record("Expected Error")
        } catch {
            let error = error as NSError
            #expect(error.domain == "foo.error")
            #expect(error.code == 2222)
            #expect(error.localizedDescription == "foo.description")
        }
        let invocations = await remote.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func details_whenRemoteDSThrowsCancellation_shouldPropagateError() async throws {
        let remote = MockMoviesRemoteDataSource()
        await remote.define(error: CancellationError(), for: .details(id: 1111))
        let sut = ConcreteMoviesRepository(remoteDataSource: remote)

        do {
            _ = try await sut.details(id: 1111)
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await remote.invocations
        #expect(invocations.count == 1)
    }
}
