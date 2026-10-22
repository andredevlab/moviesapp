import SwiftUI

@main struct MyApp: App {
    @State private var model: MoviesListViewModel

    init() {
        let client = TraktAPIClient(
            clientID: TraktConfiguration.clientID,
            transport: URLSessionTransport()
        )
        _model = State(initialValue: MoviesListViewModel(service: TraktMoviesService(client: client)))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
