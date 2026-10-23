import SwiftUI
import Core

struct DiscoverFiltersBar: View {
    let filters: MovieFilters
    let isEnabled: Bool
    let onOpen: () -> Void

    private var summary: String {
        [filters.year.map(String.init), filters.genre?.title]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onOpen) {
                Label("Filtros", systemImage: filters.isEmpty
                      ? "line.3.horizontal.decrease"
                      : "line.3.horizontal.decrease.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 13)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .foregroundStyle(filters.isEmpty ? Color.primary : DiscoverStyle.accent)
            .modifier(DiscoverGlassModifier())
            .disabled(!isEnabled)
            .accessibilityValue(summary.isEmpty ? "Nenhum filtro aplicado" : summary)

            Text(isEnabled ? (summary.isEmpty ? "Todos os filmes" : summary) : "Disponíveis nos populares")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Filtros selecionados") {
    DiscoverFiltersBar(filters: .init(year: 2024, genre: .scienceFiction), isEnabled: true) {}
        .padding()
}

#Preview("Filtros durante a busca") {
    DiscoverFiltersBar(filters: .init(), isEnabled: false) {}
        .padding()
        .preferredColorScheme(.dark)
}
#endif
