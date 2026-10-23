import SwiftUI
import Core

struct MovieMetadataView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if movie.year != nil || movie.runtime != nil {
                HStack(spacing: 10) {
                    if let year = movie.year {
                        Text(String(year))
                    }
                    if let runtime = movie.runtime {
                        Text("\(runtime) min")
                    }
                }
            }
            if !movie.genres.isEmpty {
                Text(movie.genres.prefix(2)
                    .map { $0.replacingOccurrences(of: "-", with: " ").localizedCapitalized }
                    .joined(separator: " · "))
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Metadados") {
    MovieMetadataView(movie: DiscoverPreviewData.featured)
        .padding()
}

#Preview("Sem metadados") {
    MovieMetadataView(movie: DiscoverPreviewData.withoutMetadata)
        .padding()
}
#endif
