#if DEBUG
import Core
import Foundation
import Observation

@MainActor
@Observable
final class PreviewMovieDetailsViewModel: MovieDetailsViewModel {
    var state: MovieDetailsState
    
    init(movie: Movie = DiscoverPreviewData.featured, state: MovieDetailsState? = nil) {
        self.state = state ?? MovieDetailsState(details: MovieDetails(movie: movie,
                                                                      originalTitle: "Dune: Part Two",
                                                                      tagline: "O destino de uma história escrita nas areias do deserto.",
                                                                      releaseDate: Date(timeIntervalSince1970: 1_709_251_200),
                                                                      country: "us",
                                                                      language: "en",
                                                                      languages: ["en"],
                                                                      status: "released",
                                                                      rating: 8.4,
                                                                      votes: 12500,
                                                                      certification: "PG-13",
                                                                      afterCredits: false,
                                                                      duringCredits: false))
    }
    
    func load() async {}
    func retry() async {}
}
#endif
