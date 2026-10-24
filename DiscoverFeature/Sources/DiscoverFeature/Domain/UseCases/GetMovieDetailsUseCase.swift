import Core

public protocol GetMovieDetailsUseCase: Sendable {
    func execute(id: Movie.ID) async throws -> MovieDetails
}
