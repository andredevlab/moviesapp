import SwiftUI

struct ErrorCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Não foi possível carregar", systemImage: "exclamationmark.circle")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Tentar novamente", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(DiscoverStyle.accent)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
    }
}

#if DEBUG
#Preview("Erro recuperável") {
    ErrorCard(message: "A conexão foi interrompida. Confira sua conexão e tente novamente.") {}
        .padding()
        .preferredColorScheme(.dark)
}
#endif
