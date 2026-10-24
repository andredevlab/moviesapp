import Core
import Foundation

public actor ConcreteMoviesRepository: MoviesRepository {
    private let remoteDataSource: any MoviesRemoteDataSource
    
    init(remoteDataSource: any MoviesRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<Movie> {
        let result = try await remoteDataSource.listPopular(filters: filters, page: page)
        return Page(items: result.items.map(map), pagination: result.pagination)
    }
    
    public func search(term: String, limit: Int) async throws -> MovieSearchResults {
        let movies = try await remoteDataSource.search(term: term, limit: limit)
        return MovieSearchResults(movies: movies.map(map), limit: limit)
    }
    
    public func details(id: Movie.ID) async throws -> MovieDetails {
        let details = try await remoteDataSource.details(id: id)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        dateFormatter.timeZone = .gmt
        let posterURL = details.images?.poster?.first
            .flatMap { path in URL(string: path.hasPrefix("https://") ? path : "https://\(path)")}
        
        return MovieDetails(movie: Movie(id: details.ids.trakt,
                                         title: details.title,
                                         year: details.year,
                                         overview: details.overview,
                                         runtime: details.runtime,
                                         genres: details.genres ?? [],
                                         posterURL: posterURL),
                            originalTitle: details.originalTitle,
                            tagline: details.tagline,
                            releaseDate: details.released.flatMap { dateFormatter.date(from: $0) },
                            country: details.country,
                            language: details.language,
                            languages: details.languages ?? [],
                            status: details.status,
                            rating: details.rating,
                            votes: details.votes,
                            certification: details.certification,
                            trailerURL: details.trailer.flatMap { $0.isEmpty ? nil : URL(string: $0) },
                            homepageURL: details.homepage.flatMap { $0.isEmpty ? nil : URL(string: $0) },
                            afterCredits: details.afterCredits,
                            duringCredits: details.duringCredits)
    }
    
    private func map(_ movie: TraktMovieDTO) -> Movie {
        Movie(id: movie.ids.trakt,
              title: movie.title,
              year: movie.year,
              overview: movie.overview,
              runtime: movie.runtime,
              genres: movie.genres ?? [],
              posterURL: movie.images?.poster?.first.flatMap { path in
            URL(string: path.hasPrefix("https://") ? path : "https://\(path)")
        })
    }
}
