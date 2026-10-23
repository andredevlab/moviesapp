import Core
import Foundation
import Networking

actor ConcreteMoviesRemoteDataSource: MoviesRemoteDataSource {
    private let client: any HTTPClient
    private let clientID: String
    
    /// Client IDs should come from a dedicated server over TLS.
    init(client: any HTTPClient, clientID: String = "V1T5LkIghBXTlBOevYgHoYUabMquXAKKgMPeXDLqv6k") {
        self.client = client
        self.clientID = clientID
    }
    
    func listPopular(filters: MovieFilters, page: PageRequest) async throws -> Page<TraktMovieDTO> {
        let request = try TraktPopularMoviesRequest(filters: filters, page: page, clientID: clientID)
        let response = try await client.send(request)
        
        let movies = try decode([TraktMovieDTO].self, from: response.body)
        let pagination = try parse(headers: response.headers,
                                   page: page.page,
                                   limit: page.limit,
                                   received: movies.count)
        return Page(items: movies, pagination: pagination)
    }
    
    func search(term: String, limit: Int) async throws -> [TraktMovieDTO] {
        let term = term.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !term.isEmpty else { throw MoviesRemoteDataSourceError.invalidSearchTerm }
        guard limit > 0 else { throw MoviesRemoteDataSourceError.invalidLimit }
        
        let request = try TraktSearchMoviesRequest(term: term,
                                                   limit: limit,
                                                   clientID: clientID)
        let response = try await client.send(request)
        
        let movies = try decode([TraktSearchResultDTO].self,
                                from: response.body).map(\.movie)
        return movies
    }
}

extension ConcreteMoviesRemoteDataSource {
    private func decode<Value: Decodable>(_ type: Value.Type, from body: Foundation.Data) throws -> Value {
        do {
            return try JSONDecoder().decode(type, from: body)
        } catch {
            throw MoviesRemoteDataSourceError.decoding
        }
    }
    
    func parse(headers: [String: String], page: Int, limit: Int, received: Int) throws -> Pagination {
        guard let actualPage = headers["x-pagination-page"].flatMap(Int.init), actualPage == page,
              let actualLimit = headers["x-pagination-limit"].flatMap(Int.init), actualLimit > 0,
              let pageCount = headers["x-pagination-page-count"].flatMap(Int.init), pageCount >= 0,
              let itemCount = headers["x-pagination-item-count"].flatMap(Int.init), itemCount >= 0,
              actualPage > 0, pageCount >= actualPage || (page == 1 && pageCount == 0 && itemCount == 0) else {
            throw MoviesRemoteDataSourceError.invalidPagination
        }
        
        guard actualLimit == limit, received <= limit else {
            throw MoviesRemoteDataSourceError.unexpectedPageSize(requested: limit,
                                                                 effective: actualLimit,
                                                                 received: received)
        }
        
        return Pagination(page: actualPage,
                          limit: actualLimit,
                          pageCount: pageCount,
                          itemCount: itemCount)
    }
}
