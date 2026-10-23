import SwiftUI
import Core

@MainActor
public struct MoviesView: View {
    @State private var model = ConcreteMoviesListViewModel()
    private let onOpenDiagnostics: @MainActor () -> Void

    public init(onOpenDiagnostics: @escaping @MainActor () -> Void) {
        self.onOpenDiagnostics = onOpenDiagnostics
    }

    public var body: some View {
        MoviesContentView(model: model, onOpenDiagnostics: onOpenDiagnostics)
    }
}

@MainActor
private struct MoviesContentView<ViewModel: MoviesListViewModel>: View {
    @Bindable var model: ViewModel
    @State private var showingFilters = false
    let onOpenDiagnostics: @MainActor () -> Void

    var body: some View {
        NavigationStack {
            List {
                if model.isSearching {
                    Text("Busca limitada a até 10 resultados. Filtros de ano e gênero disponíveis em Popular Movies.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                }
                ForEach(model.state.movies) { movie in
                    MovieRow(movie: movie)
                        .task { await model.paginate(currentMovieID: movie.id) }
                }

                if model.state.phase == .loadingFirstPage || model.state.phase == .paginating || model.state.phase == .debouncing {
                    HStack {
                        Spacer()
                        ProgressView(model.state.phase == .debouncing ? "Buscando…" : "Carregando…")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }

                if let error = model.state.errorMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(error).foregroundStyle(.secondary)
                        Button("Tentar novamente") {
                            Task { await model.retry() }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowSeparator(.hidden)
                } else if model.state.hasLoaded && model.state.movies.isEmpty && model.state.phase == .idle {
                    ContentUnavailableView.search(text: model.searchText)
                        .listRowSeparator(.hidden)
                }

                if model.state.hasLoaded && !model.state.movies.isEmpty && model.state.phase == .idle && model.state.errorMessage == nil {
                    if model.state.hasMore {
                        Button("Carregar mais") {
                            Task {
                                if let id = model.state.movies.last?.id {
                                    await model.paginate(currentMovieID: id)
                                }
                            }
                        }
                    } else if model.isSearching {
                        Text("Resultados desta busca carregados. Refine o termo para encontrar outros filmes.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Todos os resultados foram carregados.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Link("Dados fornecidos pelo Trakt", destination: URL(string: "https://trakt.tv")!)
                        .font(.footnote)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Popular Movies")
            .refreshable { await model.refresh() }
            .task(id: MovieQuery(term: model.searchText, filters: model.filters)) {
                if model.isSearching {
                    await model.search(term: model.searchText)
                } else {
                    await model.load()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showingFilters = true
                    } label: {
                        Label("Filtros", systemImage: model.filters.isEmpty ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill")
                    }
                    .disabled(model.isSearching)
                    Button {
                        onOpenDiagnostics()
                    } label: {
                        Label("Requisições", systemImage: "network")
                    }
                }
            }
        }
        .searchable(text: $model.searchText, prompt: "Buscar filmes")
        .sheet(isPresented: $showingFilters) {
            MovieFiltersView(filters: model.filters) { model.filters = $0 }
        }
    }
}

private struct MovieRow: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(movie.title).font(.headline)
            HStack {
                if let year = movie.year { Text(String(year)) }
                if let runtime = movie.runtime { Text("\(runtime) min") }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let overview = movie.overview, !overview.isEmpty {
                Text(overview).font(.footnote).foregroundStyle(.secondary).lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }
}
