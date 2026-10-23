import FactoryKit
import Core

public extension Container {
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
