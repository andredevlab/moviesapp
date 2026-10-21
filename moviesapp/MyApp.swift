import SwiftUI

@main struct MyApp: App {
    @State private var model: MoviesListViewModel
    @State private var diagnostics: RequestDiagnostics

    init() {
        let diagnostics = RequestDiagnostics()
        let client = TraktAPIClient(
            clientID: TraktConfiguration.clientID,
            transport: URLSessionTransport(),
            diagnostics: diagnostics
        )
        _diagnostics = State(initialValue: diagnostics)
        _model = State(initialValue: MoviesListViewModel(service: TraktMoviesService(client: client)))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model, diagnostics: diagnostics)
        }
    }
}
