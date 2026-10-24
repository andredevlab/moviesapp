import FactoryKit
import Core

public extension Container {
    var getMovieDetailsUseCase: Factory<any GetMovieDetailsUseCase> {
        self {
            ConcreteGetMovieDetailsUseCase(repository: Container.shared.moviesRepository.callAsFunction())
        }
    }

    var listPopularMoviesUseCase: Factory<any ListPopularMoviesUseCase> {
        self {
            ConcreteListPopularMoviesUseCase(repository: Container.shared.moviesRepository.callAsFunction())
        }
    }

    var searchMoviesUseCase: Factory<any SearchMoviesUseCase> {
        self {
            ConcreteSearchMoviesUseCase(repository: Container.shared.moviesRepository.callAsFunction())
        }
    }
}


extension Container {
    var posterImageLoader: Factory<PosterImageLoader> {
        self { PosterImageLoader() }.cached
    }

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
