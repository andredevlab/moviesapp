import SwiftUI

struct EmptyResultsCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let searchText: String

    var body: some View {
        ContentUnavailableView {
            Label("Nenhum filme encontrado", systemImage: "magnifyingglass")
        } description: {
            if searchText.isEmpty {
                Text("Experimente outros filtros para explorar o catálogo.")
            } else {
                Text("Não encontramos resultados para “\(searchText)”. Experimente outro título.")
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
    }
}

#if DEBUG
#Preview("Busca vazia") {
    EmptyResultsCard(searchText: "Uma viagem distante")
        .padding()
}

#Preview("Catálogo vazio") {
    EmptyResultsCard(searchText: "")
        .padding()
        .preferredColorScheme(.dark)
}
#endif
