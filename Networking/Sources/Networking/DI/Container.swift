import FactoryKit

public extension Container {
    var moviesHTTPClient: Factory<any HTTPClient> {
        self { ConcreteHTTPClient(transport: URLSessionTransport()) }
    }
}
