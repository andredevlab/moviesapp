import FactoryKit
import Networking

extension Container {
    var moviesRemoteDataSource: Factory<any MoviesRemoteDataSource> {
        self {
            ConcreteMoviesRemoteDataSource(client: Container.shared.moviesHTTPClient.callAsFunction())
        }
    }
}

public extension Container {
    var moviesRepository: Factory<MoviesRepository> {
        self {
            ConcreteMoviesRepository(remoteDataSource: Container.shared.moviesRemoteDataSource.callAsFunction())
        }
    }
}
