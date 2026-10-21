import SwiftUI

struct ContentView: View {
    let model: MoviesListViewModel
    let diagnostics: RequestDiagnostics

    var body: some View {
        MoviesView(model: model, diagnostics: diagnostics)
    }
}
