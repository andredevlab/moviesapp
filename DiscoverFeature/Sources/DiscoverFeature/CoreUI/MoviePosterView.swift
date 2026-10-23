import SwiftUI
import Core

struct MoviePosterView: View {
    let movie: Movie

    private var posterColor: Color {
        let colors = [
            Color(red: 0.19, green: 0.16, blue: 0.30),
            Color(red: 0.12, green: 0.22, blue: 0.27),
            Color(red: 0.28, green: 0.16, blue: 0.20)
        ]
        return colors[Int(movie.id.magnitude % UInt(colors.count))]
    }

    var body: some View {
        Rectangle()
            .fill(posterColor)
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .overlay {
                Image(systemName: "film.stack")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .overlay(alignment: .bottomLeading) {
                Text("CAPA INDISPONÍVEL")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel("Capa indisponível para \(movie.title)")
    }
}

#if DEBUG
#Preview("Capas de fallback") {
    HStack {
        ForEach(DiscoverPreviewData.movies.prefix(3)) { movie in
            MoviePosterView(movie: movie)
        }
    }
    .padding()
    .frame(width: 500)
}
#endif
