import Core

struct ConcreteGetMovieDetailsUseCase: GetMovieDetailsUseCase {
    private let repository: any MoviesRepository

    init(repository: any MoviesRepository) {
        self.repository = repository
    }

    func execute(id: Movie.ID) async throws -> MovieDetails {
        try await repository.details(id: id)
    }
}
