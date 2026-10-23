import SwiftUI

@MainActor
public struct MoviesView: View {
    @State private var model = ConcreteMoviesListViewModel()
    private let onOpenDiagnostics: @MainActor () -> Void

    public init(onOpenDiagnostics: @escaping @MainActor () -> Void) {
        self.onOpenDiagnostics = onOpenDiagnostics
    }

    public var body: some View {
        MoviesContentView(model: model, onOpenDiagnostics: onOpenDiagnostics)
    }
}

