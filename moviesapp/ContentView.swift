import SwiftUI
import DiscoverFeature

struct ContentView: View {
    @State private var showingDiagnostics = false

    var body: some View {
        MoviesView(onOpenDiagnostics: { showingDiagnostics = true })
            .sheet(isPresented: $showingDiagnostics) {
                RequestDiagnosticsView(entries: [])
            }
    }
}
