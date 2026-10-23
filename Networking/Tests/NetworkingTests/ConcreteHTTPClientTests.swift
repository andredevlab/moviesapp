import Foundation
import Testing

@testable import Networking

struct ConcreteHTTPClientTests {
    @Test
    func send_whenTransportDataForRequestSucceeds_shouldReturnExpectedHTTPResponse() async throws {
        let response = HTTPURLResponse(url: URL(string: "https://example.invalid/foo.resource?foo.query.key=foo.query.value")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        let transport = MockHTTPTransport(result: (Data(), response))
        let sut = ConcreteHTTPClient(transport: transport)
        
        _ = try await sut.send(MockHTTPRequest(method: "foo.method",
                                               url: URL(string: "https://example.invalid/foo.resource")!,
                                               queryItems: [URLQueryItem(name: "foo.query.key",
                                                                         value: "foo.query.value")],
                                               headers: ["foo.header.key": "foo.header.value"],
                                               body: Data("foo.body".utf8)))

        let invocations = await transport.invocations
        #expect(invocations.count == 1)
        #expect(invocations.first?.url?.absoluteString == "https://example.invalid/foo.resource?foo.query.key=foo.query.value")
        #expect(invocations.first?.method == "foo.method")
        #expect(invocations.first?.headers == ["foo.header.key": "foo.header.value"])
        #expect(String(data: invocations.first!.body!, encoding: .utf8) == "foo.body")
    }

    @Test
    func send_whenTransportDataForRequestThrowsCancellation_shouldPropagateError() async throws {
        let transport = MockHTTPTransport(error: CancellationError())

        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid/foo.failure")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected send to throw")
        } catch {
            #expect(error is CancellationError)
        }
    }

    @Test
    func send_whenTransportDataForRequestThrowsURLErrorCancelled_shouldPropagateCancellationError() async throws {
        let transport = MockHTTPTransport(error: URLError(.cancelled))

        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected send to throw")
        } catch {
            #expect(error is CancellationError)
        }
        
        let invocations = await transport.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func send_whenTaskIsCancelledDuringTransport_shouldPropagateCancellationError() async throws {
        let transport = MockHTTPTransport(error: URLError(.timedOut))
        await transport.setNeedsToBeReleased()

        let sut = ConcreteHTTPClient(transport: transport)
        let task = Task {
            try await sut.send(MockHTTPRequest(method: "GET",
                                               url: URL(string: "https://example.invalid")!,
                                               queryItems: [],
                                               headers: [:],
                                               body: nil))
        }
        await transport.waitUntilCalled()
        task.cancel()
        await transport.release()

        do {
            _ = try await task.value
            Issue.record("Expected CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        
        let invocations = await transport.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func send_whenTransportThrowsAnyHTTPError_shouldPropagateError() async throws {
        let transport = MockHTTPTransport(error: HTTPError.nonHTTPResponse)

        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected send to throw")
        } catch {
            guard case HTTPError.nonHTTPResponse = error else {
                Issue.record("Expected HTTPError.nonHTTPResponse, got \(error)")
                return
            }
            #expect((error as? HTTPError)?.errorDescription == "O transporte retornou uma resposta que não é HTTP.")
        }
        
        let invocations = await transport.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func send_whenTransportThrowsNonHTTPError_shouldWrapIntoTransportError() async throws {
        let transport = MockHTTPTransport(error: NSError(domain: "foo.domain", code: -1111))

        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected send to throw")
        } catch let error as HTTPError {
            guard case .transport(let underlying) = error else {
                Issue.record("Expected HTTPError.transport, got \(error)")
                return
            }
            #expect(error.errorDescription == "Falha no transporte HTTP.")
            #expect((underlying as NSError).domain == "foo.domain")
            #expect((underlying as NSError).code == -1111)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await transport.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func send_whenTransportThrowsAnyURLError_shouldWrapErrorWithCodeAndDescription() async throws {
        let transport = MockHTTPTransport(error: URLError(.timedOut))
        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected HTTPError.transport")
        } catch let error as HTTPError {
            guard case .transport(let underlying) = error else {
                Issue.record("Expected HTTPError.transport, got \(error)")
                return
            }
            #expect((underlying as? URLError)?.code.rawValue == -1001)
            #expect(error.errorDescription == "Falha no transporte HTTP (código -1001).")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        let invocations = await transport.invocations
        #expect(invocations.count == 1)
    }

    @Test
    func send_givenTransportDataResponse_whenHTTPRespondsStatusAboveOfSuccessRange_shouldThrowHTTPError() async throws {
        let response = HTTPURLResponse(url: URL(string: "https://example.invalid/foo.sucess.range.above")!,
                                       statusCode: 300,
                                       httpVersion: nil,
                                       headerFields: ["foo.header.key": "foo.header.value"])!
        let transport = MockHTTPTransport(result: (Data("foo.error".utf8), response))

        let sut = ConcreteHTTPClient(transport: transport)

        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid/foo.sucess.range.above")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected to throw")
        } catch let error as HTTPError {
            guard case .http(let statusCode, let headers) = error else {
                Issue.record("Expected HTTPError.http, got \(error)")
                return
            }
            #expect(error.errorDescription == "O servidor retornou HTTP 300.")
            #expect(statusCode == 300)
            #expect(headers == ["foo.header.key": "foo.header.value"])
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func send_givenTransportDataResponse_whenHTTPRespondsStatusBelowOfSuccessRange_shouldThrowHTTPError() async throws {
        let response = HTTPURLResponse(url: URL(string: "https://example.invalid/foo.sucess.range.below")!,
                                       statusCode: 199,
                                       httpVersion: nil,
                                       headerFields: ["foo.header.key": "foo.header.value"])!
        let transport = MockHTTPTransport(result: (Data("foo.error".utf8), response))
        
        let sut = ConcreteHTTPClient(transport: transport)
        
        do {
            _ = try await sut.send(MockHTTPRequest(method: "",
                                                   url: URL(string: "https://example.invalid/foo.sucess.range.below")!,
                                                   queryItems: [],
                                                   headers: [:],
                                                   body: nil))
            Issue.record("Expected to throw")
        } catch let error as HTTPError {
            guard case .http(let statusCode, let headers) = error else {
                Issue.record("Expected HTTPError.http, got \(error)")
                return
            }
            #expect(error.errorDescription == "O servidor retornou HTTP 199.")
            #expect(statusCode == 199)
            #expect(headers == ["foo.header.key": "foo.header.value"])
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
