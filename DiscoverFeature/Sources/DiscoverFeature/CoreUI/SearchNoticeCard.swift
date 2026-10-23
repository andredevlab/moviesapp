import SwiftUI

struct SearchNoticeCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Label {
            Text("Até 10 resultados por busca. Os filtros de ano e gênero estão disponíveis em Popular Movies.")
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "info.circle")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
    }
}

#if DEBUG
#Preview("Aviso de busca") {
    SearchNoticeCard()
        .padding()
        .preferredColorScheme(.dark)
}
#endif
