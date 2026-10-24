import FactoryKit
import Foundation
import Testing
@testable import DiscoverFeature

@MainActor
struct ConcreteMovieDetailsViewModelRetryTests {
    @Test
    func retry_givenPreviousError_whenUseCaseSucceeds_shouldClearErrorAndLoadDetails() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            let movie = Helper.makeMovie(id: 1111, title: "foo.title")
            await useCase.define(result: MovieDetails(movie: movie, tagline: "foo.tagline"), for: .execute(id: 1111))
            await useCase.setNeedsToBeReleased()
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111,
                                                    initialState: MovieDetailsState(errorMessage: "foo.previous.error"))

            let task = Task { await sut.retry() }
            await useCase.waitUntilCalled()
            #expect(sut.state.errorMessage == nil)
            #expect(sut.state.isLoading)
            await useCase.release()
            await task.value

            #expect(sut.state.details?.tagline == "foo.tagline")
            #expect(sut.state.errorMessage == nil)
            #expect(!sut.state.isLoading)
            let invocations = await useCase.invocations
            #expect(invocations.count == 1)
            guard let first = invocations.first, case let .execute(invokedID) = first else {
                Issue.record("Expected execute invocation"); return
            }
            #expect(invokedID == 1111)
        }
    }

    @Test
    func retry_givenPreviousError_whenUseCaseThrows_shouldUpdateErrorAndKeepDetailsEmpty() async {
        await Container.$shared.withValue(Container()) {
            let useCase = MockGetMovieDetailsUseCase()
            await useCase.define(error: NSError(domain: "foo.error", code: 2222,
                                                 userInfo: [NSLocalizedDescriptionKey: "foo.new.error"]),
                                 for: .execute(id: 1111))
            Container.shared.getMovieDetailsUseCase.register { useCase }
            let sut = ConcreteMovieDetailsViewModel(movieID: 1111,
                                                    initialState: MovieDetailsState(errorMessage: "foo.previous.error"))

            await sut.retry()

            #expect(sut.state.errorMessage == "foo.new.error")
            #expect(!sut.state.isLoading)
            #expect(sut.state.details == nil)
            let invocations = await useCase.invocations
            #expect(invocations.count == 1)
        }
    }
}
