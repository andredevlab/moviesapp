import Core
import FactoryKit
import Foundation
import Observation

@MainActor
@Observable
final class ConcreteMovieDetailsViewModel: MovieDetailsViewModel {
    @ObservationIgnored @Injected(\.getMovieDetailsUseCase) private var getMovieDetailsUseCase
    
    private let movieID: Movie.ID
    private(set) var state: MovieDetailsState
    
    init(movieID: Movie.ID,
         initialState: MovieDetailsState? = nil) {
        self.movieID = movieID
        state = initialState ?? MovieDetailsState()
    }
    
    func load() async {
        guard state.errorMessage == nil else { return }
        await fetchDetails()
    }
    
    func retry() async {
        await fetchDetails()
    }
    
    private func fetchDetails() async {
        guard state.details == nil,
              !state.isLoading,
              !Task.isCancelled else { return }
        
        defer { state.isLoading = false }
        
        state.isLoading = true
        state.errorMessage = nil
        
        
        do {
            let details = try await getMovieDetailsUseCase.execute(id: movieID)
            try Task.checkCancellation()
            state.details = details
        } catch {
            guard !Task.isCancelled,
                  !(error is CancellationError),
                  (error as? URLError)?.code != .cancelled else { return }
            state.errorMessage = error.localizedDescription
        }
    }
}
