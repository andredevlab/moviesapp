import Foundation
import Networking

actor MockHTTPClient: HTTPClient {
    struct Invocation: Sendable {
        let method: String
        let url: URL
        let queryItems: [URLQueryItem]
        let headers: [String: String]
        let body: Foundation.Data?
    }

    private(set) var invocations: [Invocation] = []
    private let result: Result<HTTPResponse, any Error>
    private var needsToBeReleased = false
    private var releaseContinuation: CheckedContinuation<Void, any Error>?
    private var callContinuation: CheckedContinuation<Void, Never>?

    init(result: HTTPResponse) {
        self.result = .success(result)
    }

    init(error: any Error) {
        self.result = .failure(error)
    }

    func setNeedsToBeReleased() {
        needsToBeReleased = true
    }

    func waitUntilCalled() async {
        guard invocations.isEmpty else { return }
        await withCheckedContinuation { callContinuation = $0 }
    }

    func release() {
        needsToBeReleased = false
        releaseContinuation?.resume()
        releaseContinuation = nil
    }

    func send(_ request: any HTTPRequest) async throws -> HTTPResponse {
        invocations.append(Invocation(method: request.method,
                                      url: request.url,
                                      queryItems: request.queryItems,
                                      headers: request.headers,
                                      body: request.body))
        callContinuation?.resume()
        callContinuation = nil

        if needsToBeReleased {
            try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                    if Task.isCancelled {
                        continuation.resume(throwing: CancellationError())
                    } else {
                        releaseContinuation = continuation
                    }
                }
            } onCancel: {
                Task { await self.cancelPendingCall() }
            }
        }
        return try result.get()
    }

    private func cancelPendingCall() {
        releaseContinuation?.resume(throwing: CancellationError())
        releaseContinuation = nil
    }
}
