import SwiftUI

struct MoviesPaginationFooter: View {
    let hasMore: Bool
    let endMessage: String
    let onLoadMore: () -> Void

    var body: some View {
        Group {
            if hasMore {
                Button(action: onLoadMore) {
                    Label("Carregar mais", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .modifier(DiscoverGlassModifier())
            } else {
                Text(endMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview("Paginação") {
    VStack(spacing: 24) {
        MoviesPaginationFooter(hasMore: true, endMessage: "") {}
        MoviesPaginationFooter(hasMore: false, endMessage: "Todos os resultados foram carregados.") {}
    }
    .padding()
    .preferredColorScheme(.dark)
}
#endif
