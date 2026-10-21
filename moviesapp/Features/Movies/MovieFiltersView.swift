import SwiftUI

struct MovieFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var yearText: String
    @State private var genre: MovieGenre?
    let apply: (MovieFilters) -> Void

    init(filters: MovieFilters, apply: @escaping (MovieFilters) -> Void) {
        _yearText = State(initialValue: filters.year.map(String.init) ?? "")
        _genre = State(initialValue: filters.genre)
        self.apply = apply
    }

    private var trimmedYear: String { yearText.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isValidYear: Bool {
        trimmedYear.isEmpty || (trimmedYear.count == 4 && trimmedYear.allSatisfy(\.isNumber) && Int(trimmedYear) != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ano de lançamento") {
                    TextField("Todos os anos", text: $yearText)
                    if !isValidYear { Text("Informe um ano com quatro dígitos.").foregroundStyle(.red) }
                }
                Section("Gênero") {
                    Picker("Gênero", selection: $genre) {
                        Text("Todos").tag(Optional<MovieGenre>.none)
                        ForEach(MovieGenre.allCases) { genre in
                            Text(genre.title).tag(Optional(genre))
                        }
                    }
                }
                Button("Limpar filtros") {
                    yearText = ""
                    genre = nil
                }
            }
            .navigationTitle("Filtros")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        apply(MovieFilters(year: Int(trimmedYear), genre: genre))
                        dismiss()
                    }
                    .disabled(!isValidYear)
                }
            }
        }
    }
}
