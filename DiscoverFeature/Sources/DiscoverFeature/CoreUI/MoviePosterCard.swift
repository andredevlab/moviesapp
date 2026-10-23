import SwiftUI
import Core

struct MoviePosterCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MoviePosterView(movie: movie)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                MovieMetadataView(movie: movie)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Card de filme") {
    MoviePosterCard(movie: DiscoverPreviewData.featured)
        .frame(width: 190)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Título longo") {
    MoviePosterCard(movie: DiscoverPreviewData.longTitle)
        .frame(width: 220)
        .padding()
}
#endif
