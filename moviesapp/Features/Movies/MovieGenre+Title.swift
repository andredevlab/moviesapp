import Core

extension MovieGenre {
    var title: String {
        switch self {
        case .action: "Ação"
        case .adventure: "Aventura"
        case .comedy: "Comédia"
        case .drama: "Drama"
        case .horror: "Terror"
        case .scienceFiction: "Ficção científica"
        case .thriller: "Suspense"
        }
    }
}
