import FactoryKit
import Networking

extension Container {
    var moviesRemoteDataSource: ParameterFactory<String, any MoviesRemoteDataSource> {
        self { clientID in
            ConcreteMoviesRemoteDataSource(client: self.moviesHTTPClient(), clientID: clientID)
        }
    }
}

public extension Container {
    var moviesRepository: ParameterFactory<String, any MoviesRepository> {
        self { clientID in
            ConcreteMoviesRepository(remoteDataSource: self.moviesRemoteDataSource(clientID))
        }
    }
}
