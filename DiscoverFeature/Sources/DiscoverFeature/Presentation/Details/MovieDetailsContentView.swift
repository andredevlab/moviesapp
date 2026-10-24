import Core
import SwiftUI

@MainActor
struct MovieDetailsContentView<ViewModel: MovieDetailsViewModel>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
    
    @Bindable var model: ViewModel
    @State private var retryAttempt = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DiscoverStyle.spacing) {
                if model.state.isLoading {
                    LoadingCard(title: "Carregando detalhes…")
                }
                if let message = model.state.errorMessage {
                    ErrorCard(message: message) { retryAttempt += 1 }
                }
                
                if let details = model.state.details {
                    header(details)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sinopse").font(.title2.bold())
                        Text(nonblank(details.movie.overview) ?? "Sinopse indisponível.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(DiscoverStyle.surface(for: colorScheme),
                                in: RoundedRectangle(cornerRadius: DiscoverStyle.cornerRadius))
                    
                    information(details)
                    if details.trailerURL != nil || details.homepageURL != nil {
                        VStack(spacing: 12) {
                            if let url = details.trailerURL {
                                Link(destination: url) {
                                    Label("Assistir ao trailer", systemImage: "play.circle")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            if let url = details.homepageURL {
                                Link(destination: url) {
                                    Label("Site oficial", systemImage: "safari")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                TraktAttributionView()
                    .frame(maxWidth: .infinity)
            }
            .padding(DiscoverStyle.spacing)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(DiscoverStyle.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Detalhes")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .tint(DiscoverStyle.accent)
        .task(id: retryAttempt) {
            if retryAttempt == 0 {
                await model.load()
            } else {
                await model.retry()
            }
        }
    }
    
    private func header(_ details: MovieDetails) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 24) {
                    poster(details.movie)
                    headline(details)
                }
            } else {
                HStack(alignment: .top, spacing: 24) {
                    poster(details.movie)
                    headline(details)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func poster(_ movie: Movie) -> some View {
        MoviePosterView(movie: movie)
            .frame(width: dynamicTypeSize.isAccessibilitySize ? 160 : 128)
            .accessibilityHidden(true)
    }
    
    private func headline(_ details: MovieDetails) -> some View {
        let movie = details.movie
        return VStack(alignment: .leading, spacing: 12) {
            Text(movie.title)
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)
            if movie.year != nil || movie.runtime != nil {
                HStack(spacing: 10) {
                    if let year = movie.year { Text(String(year)) }
                    if let runtime = movie.runtime { Text("\(runtime) min") }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            if !movie.genres.isEmpty {
                Text(movie.genres.map {
                    $0.replacingOccurrences(of: "-", with: " ").localizedCapitalized
                }.joined(separator: " · "))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            if let tagline = nonblank(details.tagline) {
                Text(tagline).font(.subheadline.italic()).foregroundStyle(.secondary)
            }
            if details.votes == 0 {
                Text("Ainda sem avaliações").font(.subheadline).foregroundStyle(.secondary)
            } else if let rating = details.rating {
                Label {
                    Text("\(rating, format: .number.precision(.fractionLength(1))) / 10 no Trakt")
                } icon: {
                    Image(systemName: "star.fill").foregroundStyle(DiscoverStyle.accent)
                }
                .font(.subheadline.weight(.semibold))
                if let votes = details.votes {
                    Text("\(votes) avaliações").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func information(_ details: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = nonblank(details.originalTitle), title != details.movie.title {
                informationRow("Título original", value: title)
            }
            if let date = details.releaseDate {
                informationRow("Lançamento",
                               value: date.formatted(Date.FormatStyle(date: .abbreviated,
                                                                      time: .omitted,
                                                                      locale: locale,
                                                                      timeZone: .gmt)))
            }
            if let country = nonblank(details.country) {
                informationRow("País",
                               value: locale.localizedString(forRegionCode: country) ?? country.uppercased())
            }
            if let language = nonblank(details.language) {
                informationRow("Idioma original",
                               value: locale.localizedString(forLanguageCode: language) ?? language)
            }
            if !details.languages.isEmpty {
                informationRow("Idiomas",
                               value: details.languages.map {
                    locale.localizedString(forLanguageCode: $0) ?? $0
                }.joined(separator: ", "))
            }
            if let certification = nonblank(details.certification) {
                informationRow("Classificação indicativa", value: certification)
            }
            if let status = nonblank(details.status) {
                informationRow("Status", value: statusTitle(status))
            }
            if let afterCredits = details.afterCredits {
                informationRow("Cenas após os créditos", value: afterCredits ? "Sim" : "Não")
            }
            if let duringCredits = details.duringCredits {
                informationRow("Cenas durante os créditos", value: duringCredits ? "Sim" : "Não")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func informationRow(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
    
    private func nonblank(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        return value
    }
    
    private func statusTitle(_ status: String) -> String {
        switch status {
        case "released": "Lançado"
        case "in production": "Em produção"
        case "post production": "Em pós-produção"
        case "planned": "Planejado"
        case "rumored": "Rumor"
        case "canceled": "Cancelado"
        default: status
        }
    }
}

#if DEBUG
#Preview("Detalhes • claro") {
    NavigationStack { MovieDetailsContentView(model: PreviewMovieDetailsViewModel()) }
}

#Preview("Detalhes • escuro") {
    NavigationStack { MovieDetailsContentView(model: PreviewMovieDetailsViewModel()) }
        .preferredColorScheme(.dark)
}

#Preview("Sem metadados") {
    NavigationStack {
        MovieDetailsContentView(model: PreviewMovieDetailsViewModel(
            movie: DiscoverPreviewData.withoutMetadata,
            state: MovieDetailsState(details: MovieDetails(movie: DiscoverPreviewData.withoutMetadata))
        ))
    }
}

#Preview("Carregando detalhes") {
    NavigationStack {
        MovieDetailsContentView(model: PreviewMovieDetailsViewModel(state: MovieDetailsState(isLoading: true)))
    }
}

#Preview("Falha nos detalhes") {
    NavigationStack {
        MovieDetailsContentView(model: PreviewMovieDetailsViewModel(
            state: MovieDetailsState(errorMessage: "A conexão foi interrompida. Tente novamente.")
        ))
    }
}

#Preview("Detalhes acessíveis") {
    let movie = Movie(
        id: 6,
        title: "Tudo em Todo o Lugar ao Mesmo Tempo",
        year: 2022,
        overview: String(repeating: "Uma mulher atravessa universos e encontra diferentes versões de si mesma, enquanto tenta preservar os laços com sua família. ", count: 6),
        runtime: 139,
        genres: ["adventure", "comedy", "science-fiction", "drama"]
    )
    NavigationStack {
        MovieDetailsContentView(model: PreviewMovieDetailsViewModel(movie: movie))
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
