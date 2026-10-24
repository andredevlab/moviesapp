import SwiftUI
import Core
import FactoryKit

struct MoviePosterView: View {
    @Injected(\.posterImageLoader) private var posterImageLoader
    @State private var phase: AsyncImagePhase = .empty
    let movie: Movie
    
    private var isLoading: Bool {
        movie.posterURL != nil && phase.image == nil && phase.error == nil
    }
    
    private var posterColor: Color {
        let colors = [Color(red: 0.19, green: 0.16, blue: 0.30),
                      Color(red: 0.12, green: 0.22, blue: 0.27),
                      Color(red: 0.28, green: 0.16, blue: 0.20)]
        return colors[Int(movie.id.magnitude % UInt(colors.count))]
    }
    
    var body: some View {
        Rectangle()
            .fill(posterColor)
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .overlay {
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "film.stack")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
            .overlay(alignment: .bottomLeading) {
                if phase.image == nil {
                    Text(isLoading ? "CARREGANDO CAPA" : "CAPA INDISPONÍVEL")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel(phase.image == nil ? "Capa indisponível para \(movie.title)" : "Capa de \(movie.title)")
            .task(id: movie.posterURL) {
                phase = .empty
                guard let url = movie.posterURL else { return }
                
                do {
                    let image = try await posterImageLoader.image(for: url)
                    try Task.checkCancellation()
                    phase = .success(Image(decorative: image, scale: 1))
                } catch {
                    guard !Task.isCancelled else { return }
                    phase = .failure(error)
                }
            }
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
