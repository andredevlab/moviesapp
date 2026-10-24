import Core
@testable import DiscoverFeature

actor MockGetMovieDetailsUseCase: GetMovieDetailsUseCase {
    enum Invocation: Hashable, Sendable {
        case execute(id: Movie.ID)
    }

    enum Failure: Error {
        case unexpectedInvocation(Invocation)
    }

    private(set) var invocations: [Invocation] = []
    private var results: [Invocation: Result<MovieDetails, any Error>] = [:]
    private var needsToBeReleased = false
    private var callContinuation: CheckedContinuation<Void, Never>?
    private var releaseContinuation: CheckedContinuation<Void, Never>?

    func define(result: MovieDetails, for invocation: Invocation) {
        results[invocation] = .success(result)
    }

    func define(error: any Error, for invocation: Invocation) {
        results[invocation] = .failure(error)
    }

    func setNeedsToBeReleased() { needsToBeReleased = true }

    func waitUntilCalled() async {
        guard invocations.isEmpty else { return }
        await withCheckedContinuation { callContinuation = $0 }
    }

    func release() {
        needsToBeReleased = false
        releaseContinuation?.resume()
        releaseContinuation = nil
    }

    func execute(id: Movie.ID) async throws -> MovieDetails {
        let invocation = Invocation.execute(id: id)
        invocations.append(invocation)
        callContinuation?.resume()
        callContinuation = nil
        guard let result = results[invocation] else { throw Failure.unexpectedInvocation(invocation) }
        if needsToBeReleased {
            // Deliberately finish after cancellation to exercise the ViewModel's stale-result check.
            await withCheckedContinuation { releaseContinuation = $0 }
        }
        return try result.get()
    }
}
