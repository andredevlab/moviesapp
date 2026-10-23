import SwiftUI
import Core

@MainActor
struct MoviesContentView<ViewModel: MoviesListViewModel>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var model: ViewModel
    @State private var showingFilters = false
    let onOpenDiagnostics: @MainActor () -> Void

    private var featuredMovie: Movie? {
        model.isSearching ? nil : model.state.movies.first
    }

    private var gridMovies: [Movie] {
        featuredMovie == nil ? model.state.movies : Array(model.state.movies.dropFirst())
    }

    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible(), alignment: .top)]
            : [GridItem(.adaptive(minimum: 150, maximum: 230), spacing: 16, alignment: .top)]
    }

    private var loadingTitle: String? {
        switch model.state.phase {
        case .debouncing: "Buscando…"
        case .loadingFirstPage: "Carregando filmes…"
        case .paginating: "Carregando mais filmes…"
        case .idle, .refreshing: nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DiscoverStyle.spacing) {
                    DiscoverHeaderView(
                        title: model.isSearching ? "Resultados" : "Popular Movies",
                        subtitle: model.isSearching
                            ? "Encontre sua próxima história."
                            : "O que está em alta no Trakt."
                    )

                    if model.isSearching {
                        SearchNoticeCard()
                    }

                    if let movie = featuredMovie {
                        MovieFeaturedCard(movie: movie)
                            .task { await model.paginate(currentMovieID: movie.id) }
                    }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        ForEach(gridMovies) { movie in
                            MoviePosterCard(movie: movie)
                                .task { await model.paginate(currentMovieID: movie.id) }
                        }
                    }

                    if let loadingTitle {
                        LoadingCard(title: loadingTitle)
                    }

                    if let error = model.state.errorMessage {
                        ErrorCard(message: error) {
                            Task { await model.retry() }
                        }
                    } else if model.state.hasLoaded && model.state.movies.isEmpty && model.state.phase == .idle {
                        EmptyResultsCard(searchText: model.searchText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }

                    if model.state.hasLoaded && !model.state.movies.isEmpty && model.state.phase == .idle && model.state.errorMessage == nil {
                        MoviesPaginationFooter(
                            hasMore: model.state.hasMore,
                            endMessage: model.isSearching
                                ? "Resultados desta busca carregados. Refine o termo para encontrar outros filmes."
                                : "Todos os resultados foram carregados."
                        ) {
                            if let id = model.state.movies.last?.id {
                                Task { await model.paginate(currentMovieID: id) }
                            }
                        }
                    }

                    TraktAttributionView()
                }
                .padding(DiscoverStyle.spacing)
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity)
            }
            .background(DiscoverStyle.background(for: colorScheme).ignoresSafeArea())
            .safeAreaInset(edge: .top, spacing: 0) {
                DiscoverFiltersBar(filters: model.filters, isEnabled: !model.isSearching) {
                    showingFilters = true
                }
                .padding(.horizontal, DiscoverStyle.spacing)
                .padding(.vertical, 8)
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Descobrir")
            .refreshable { await model.refresh() }
            .task(id: MovieQuery(term: model.searchText, filters: model.filters)) {
                if model.isSearching {
                    await model.search(term: model.searchText)
                } else {
                    await model.load()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onOpenDiagnostics) {
                        Label("Requisições", systemImage: "network")
                    }
                }
            }
        }
        .tint(DiscoverStyle.accent)
        .searchable(text: $model.searchText, prompt: "Buscar filmes")
        .sheet(isPresented: $showingFilters) {
            MovieFiltersView(filters: model.filters) { model.filters = $0 }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#if DEBUG
#Preview("Populares • claro") {
    MoviesContentView(model: PreviewMoviesViewModel(), onOpenDiagnostics: {})
        .preferredColorScheme(.light)
}

#Preview("Populares • escuro") {
    MoviesContentView(model: PreviewMoviesViewModel(), onOpenDiagnostics: {})
        .preferredColorScheme(.dark)
}

#Preview("Busca") {
    MoviesContentView(
        model: PreviewMoviesViewModel(searchText: "Duna", hasMore: false),
        onOpenDiagnostics: {}
    )
}

#Preview("Carregamento inicial") {
    MoviesContentView(
        model: PreviewMoviesViewModel(movies: [], phase: .loadingFirstPage, hasLoaded: false),
        onOpenDiagnostics: {}
    )
}

#Preview("Debounce") {
    MoviesContentView(
        model: PreviewMoviesViewModel(movies: [], searchText: "Duna", phase: .debouncing, hasLoaded: false),
        onOpenDiagnostics: {}
    )
}

#Preview("Paginação") {
    MoviesContentView(model: PreviewMoviesViewModel(phase: .paginating), onOpenDiagnostics: {})
}

#Preview("Erro") {
    MoviesContentView(
        model: PreviewMoviesViewModel(movies: [], errorMessage: "A conexão com o servidor foi interrompida."),
        onOpenDiagnostics: {}
    )
}

#Preview("Sem resultados") {
    MoviesContentView(
        model: PreviewMoviesViewModel(movies: [], searchText: "Uma viagem distante", hasMore: false),
        onOpenDiagnostics: {}
    )
}

#Preview("Texto acessível") {
    MoviesContentView(model: PreviewMoviesViewModel(), onOpenDiagnostics: {})
        .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
