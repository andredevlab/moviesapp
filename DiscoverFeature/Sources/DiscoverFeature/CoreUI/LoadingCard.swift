import SwiftUI

struct LoadingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            ProgressView()
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Carregamento") {
    VStack(spacing: 16) {
        LoadingCard(title: "Carregando filmes…")
        LoadingCard(title: "Buscando…")
        LoadingCard(title: "Carregando mais filmes…")
    }
    .padding()
}
#endif
