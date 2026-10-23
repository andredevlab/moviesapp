import SwiftUI
import Core
import DiscoverFeature
import FactoryKit

@main struct MyApp: App {
    @State private var model: MoviesListViewModel
    
    init() {
        let viewModel = MoviesListViewModel(listPopularMoviesUseCase: Container.shared.listPopularMoviesUseCase.callAsFunction(),
                                            searchMoviesUseCase: Container.shared.searchMoviesUseCase.callAsFunction())
        _model = State(initialValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
