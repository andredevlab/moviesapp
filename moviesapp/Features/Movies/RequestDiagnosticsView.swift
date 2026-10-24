import SwiftUI

struct RequestDiagnosticsView: View {
    struct Entry: Identifiable {
        let id = UUID()
        let date: Date
        let pathAndQuery: String
        let statusCode: Int?
        let headers: [String: String]
        let networkBytes: Int
        let failure: String?
    }

    let entries: [Entry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "Funcionalidade prevista como evolução",
                        systemImage: "network",
                        description: Text("Telemetria ainda não implementada.")
                    )
                }
                ForEach(entries) { entry in
                    Section {
                        Text(entry.pathAndQuery).font(.caption.monospaced())
                        Text(entry.date, format: .dateTime.hour().minute().second())
                        Text(entry.statusCode.map { "HTTP \($0)" } ?? "Sem resposta HTTP")
                        Text("Corpo recebido: \(entry.networkBytes) bytes")
                        ForEach(entry.headers.keys.sorted(), id: \.self) { name in
                            Text("\(name): \(entry.headers[name] ?? "")").font(.caption.monospaced())
                        }
                        if let failure = entry.failure { Text(failure).foregroundStyle(.red) }
                    }
                }
            }
            .textSelection(.enabled)
            .navigationTitle("Requisições")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Fechar") { dismiss() } }
            }
        }
    }
}
