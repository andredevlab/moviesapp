import Core
import SwiftUI

@MainActor
struct MovieDetailsView: View {
    @State private var model: ConcreteMovieDetailsViewModel

    init(movieID: Movie.ID) {
        _model = State(initialValue: ConcreteMovieDetailsViewModel(movieID: movieID))
    }

    var body: some View {
        MovieDetailsContentView(model: model)
    }
}
