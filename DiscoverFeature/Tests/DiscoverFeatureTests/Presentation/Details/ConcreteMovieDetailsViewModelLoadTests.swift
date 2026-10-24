import FactoryKit
import Foundation
import Testing
@testable import DiscoverFeature

@MainActor
struct ConcreteMovieDetailsViewModelLoadTests {
    @Test
    func load_givenUseCaseIsSuspended_whenUseCaseSucceeds_shouldPublishReturnedMovieAndFinishLoading() async throws {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            let resolvedMovie = Helper.makeMovie(id: 1111, title: "foo.resolved.title", overview: "foo.overview")
            let details = MovieDetails(movie: resolvedMovie, tagline: "foo.tagline", rating: 8.5)
            await useCase.define(result: details, for: .execute(id: 1111))
            await useCase.setNeedsToBeReleased()
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111)

            let task = Task { await sut.load() }
            await useCase.waitUntilCalled()
            #expect(sut.state.isLoading)
            #expect(sut.state.details == nil)
            await useCase.release()
            await task.value

            let invocations = await useCase.invocations
            #expect(invocations.count == 1)
            guard let first = invocations.first, case let .execute(invokedID) = first else {
                Issue.record("Expected execute invocation"); return
            }
            #expect(invokedID == 1111)
            #expect(sut.state.details?.movie.title == "foo.resolved.title")
            #expect(sut.state.details?.movie.overview == "foo.overview")
            #expect(sut.state.details?.tagline == "foo.tagline")
            #expect(sut.state.details?.rating == 8.5)
            #expect(!sut.state.isLoading)
            #expect(sut.state.errorMessage == nil)
        }
    }

    @Test
    func load_whenUseCaseThrows_shouldShowErrorAndKeepDetailsEmpty() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            await useCase.define(error: NSError(domain: "foo.error", code: 2222,
                                                 userInfo: [NSLocalizedDescriptionKey: "foo.description"]),
                                 for: .execute(id: 1111))
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111)

            await sut.load()

            #expect(sut.state.errorMessage == "foo.description")
            #expect(sut.state.details == nil)
            #expect(!sut.state.isLoading)
            let invocations = await useCase.invocations
            #expect(invocations.count == 1)
        }
    }

    @Test
    func load_givenPreviousError_whenLoading_shouldWaitForExplicitRetry() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111,
                                                    initialState: MovieDetailsState(errorMessage: "foo.previous.error"))

            await sut.load()

            let invocations = await useCase.invocations
            #expect(invocations.count == 0)
            #expect(sut.state.errorMessage == "foo.previous.error")
        }
    }

    @Test
    func load_givenRequestInProgress_whenLoading_shouldAvoidConcurrentRequest() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111,
                                                    initialState: MovieDetailsState(isLoading: true))

            await sut.load()

            let invocations = await useCase.invocations
            #expect(invocations.count == 0)
        }
    }

    @Test
    func load_givenUseCaseIsSuspended_whenTaskIsCancelled_shouldDiscardLateResponseWithoutError() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            let resolvedMovie = Helper.makeMovie(id: 1111, title: "foo.resolved.title")
            await useCase.define(result: MovieDetails(movie: resolvedMovie), for: .execute(id: 1111))
            await useCase.setNeedsToBeReleased()
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111)

            let task = Task { await sut.load() }
            await useCase.waitUntilCalled()
            task.cancel()
            await useCase.release()
            await task.value

            #expect(sut.state.details == nil)
            #expect(sut.state.errorMessage == nil)
            #expect(!sut.state.isLoading)
            let invocations = await useCase.invocations
            #expect(invocations.count == 1)
        }
    }

    @Test
    func load_whenUseCaseThrowsURLCancellation_shouldFinishWithoutError() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            await useCase.define(error: URLError(.cancelled), for: .execute(id: 1111))
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111)

            await sut.load()

            #expect(sut.state.errorMessage == nil)
            #expect(sut.state.details == nil)
            #expect(!sut.state.isLoading)
        }
    }
}
