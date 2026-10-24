import Core
import Foundation
import Testing
@testable import DiscoverFeature

struct ConcreteGetMovieDetailsUseCaseExecuteTests {
    @Test
    func execute_whenRepositorySucceeds_shouldReturnExpectedMovieDetails() async throws {
        let repository = MockMoviesRepository()
        let movie = Movie(id: 1111, title: "foo.title", year: 2222, overview: "foo.overview",
                          runtime: 3333, genres: ["foo.genre"],
                          posterURL: URL(string: "https://example.com/foo.poster.webp"))
        let details = MovieDetails(movie: movie, originalTitle: "foo.original.title", tagline: "foo.tagline",
                                   releaseDate: Date(timeIntervalSince1970: 1_709_251_200), country: "br",
                                   language: "pt", languages: ["pt", "en"], status: "released", rating: 8.5,
                                   votes: 4444, certification: "foo.certification",
                                   trailerURL: URL(string: "https://example.com/foo.trailer"),
                                   homepageURL: URL(string: "https://example.com/foo.homepage"),
                                   afterCredits: true, duringCredits: false)
        await repository.define(result: details, for: .details(id: 1111))
        let sut = ConcreteGetMovieDetailsUseCase(repository: repository)

        let result = try await sut.execute(id: 1111)

        let invocations = await repository.invocations
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
        #expect(result.movie.genres == ["foo.genre"])
        #expect(result.movie.posterURL?.absoluteString == "https://example.com/foo.poster.webp")
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
    func execute_whenRepositoryThrowsAnyError_shouldPropagateError() async throws {
        let repository = MockMoviesRepository()
        await repository.define(error: NSError(domain: "foo.error", code: 2222,
                                                userInfo: [NSLocalizedDescriptionKey: "foo.description"]),
                                for: .details(id: 1111))
        let sut = ConcreteGetMovieDetailsUseCase(repository: repository)

        do {
            _ = try await sut.execute(id: 1111)
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
        await repository.define(error: CancellationError(), for: .details(id: 1111))
        let sut = ConcreteGetMovieDetailsUseCase(repository: repository)

        do {
            _ = try await sut.execute(id: 1111)
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        let invocations = await repository.invocations
        #expect(invocations.count == 1)
    }
}
