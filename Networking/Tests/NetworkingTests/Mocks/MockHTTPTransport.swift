import Foundation
@testable import Networking

actor MockHTTPTransport: HTTPTransport {
    struct Invocation: Equatable, Sendable {
        let url: URL?
        let method: String?
        let headers: [String: String]
        let body: Data?
    }
    
    enum Failure: Error {
        case unexpectedInvocation(Invocation)
    }
    
    private(set) var invocations: [Invocation] = []
    private var needsToBeReleased = false
    private var releaseContinuation: CheckedContinuation<Void, Never>?
    private var callContinuation: CheckedContinuation<Void, Never>?
    private let onCall: (@Sendable () async -> Void)?
    private let result: Result<(Data, HTTPURLResponse), any Error>
    
    init(result: (Data, HTTPURLResponse), onCall: (@Sendable () async -> Void)? = nil) {
        self.onCall = onCall
        self.result = .success(result)
    }
    
    init(error: any Error, onCall: (@Sendable () async -> Void)? = nil) {
        self.onCall = onCall
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

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let headers = (request.allHTTPHeaderFields ?? [:]).reduce(into: [String: String]()) { result, header in
            result[header.key.lowercased()] = header.value
        }
        let invocation = Invocation(url: request.url,
                                    method: request.httpMethod,
                                    headers: headers,
                                    body: request.httpBody)
        invocations.append(invocation)
        callContinuation?.resume()
        callContinuation = nil

        if needsToBeReleased {
            await withCheckedContinuation { releaseContinuation = $0 }
        }

        await onCall?()
        return try result.get()
    }
}
