import SwiftUI

struct ContentView: View {
    let model: MoviesListViewModel

    var body: some View {
        MoviesView(model: model)
    }
}
