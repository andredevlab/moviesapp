#if DEBUG
import Core

enum DiscoverPreviewData {
    static let featured = Movie(
        id: 1,
        title: "Duna: Parte Dois",
        year: 2024,
        overview: "Paul Atreides se une a Chani e aos Fremen em uma jornada pelo deserto, dividido entre o amor e o destino do universo.",
        runtime: 166,
        genres: ["adventure", "science-fiction"]
    )

    static let withoutMetadata = Movie(
        id: 5, title: "Ainda Estou Aqui", year: nil, overview: nil, runtime: nil, genres: []
    )

    static let longTitle = Movie(
        id: 6,
        title: "Tudo em Todo o Lugar ao Mesmo Tempo",
        year: 2022,
        overview: nil,
        runtime: 139,
        genres: ["adventure", "comedy"]
    )

    static let movies = [
        featured,
        Movie(id: 2, title: "Interestelar", year: 2014, overview: nil,
              runtime: 169, genres: ["science-fiction", "drama"]),
        Movie(id: 3, title: "A Substância", year: 2024, overview: nil,
              runtime: 141, genres: ["horror"]),
        Movie(id: 4, title: "Vidas Passadas", year: 2023, overview: nil,
              runtime: 106, genres: ["drama", "romance"]),
        withoutMetadata,
        longTitle
    ]
}
#endif
