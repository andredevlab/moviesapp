import Observation

struct MovieDetailsState {
    var details: MovieDetails?
    var isLoading = false
    var errorMessage: String?
}

@MainActor
protocol MovieDetailsViewModel: AnyObject, Observable {
    var state: MovieDetailsState { get }

    func load() async
    func retry() async
}
