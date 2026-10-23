import SwiftUI

struct TraktAttributionView: View {
    var body: some View {
        Link(destination: URL(string: "https://trakt.tv")!) {
            Text("Dados fornecidos pelo Trakt")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("Atribuição") {
    TraktAttributionView()
        .padding()
}
#endif
