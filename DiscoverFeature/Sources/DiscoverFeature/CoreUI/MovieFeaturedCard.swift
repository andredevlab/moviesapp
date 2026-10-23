import SwiftUI
import Core

struct MovieFeaturedCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let movie: Movie

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 20) {
                    poster.frame(maxWidth: 180)
                    details
                }
            } else {
                HStack(alignment: .top, spacing: 20) {
                    poster.frame(width: 112)
                    details
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DiscoverStyle.surface(for: colorScheme),
                    in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
        .accessibilityElement(children: .combine)
    }

    private var poster: some View {
        MoviePosterView(movie: movie)
            .accessibilityHidden(true)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EM ALTA")
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
            Text(movie.title)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
            MovieMetadataView(movie: movie)
            if let overview = movie.overview, !overview.isEmpty {
                Text(overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview("Destaque") {
    MovieFeaturedCard(movie: DiscoverPreviewData.featured)
        .padding()
        .background(DiscoverStyle.background(for: .dark))
        .preferredColorScheme(.dark)
}

#Preview("Destaque acessível") {
    MovieFeaturedCard(movie: DiscoverPreviewData.featured)
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
