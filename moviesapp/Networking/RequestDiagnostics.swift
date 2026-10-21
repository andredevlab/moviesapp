import Foundation
import Observation

@MainActor
@Observable
final class RequestDiagnostics {
    struct Entry: Identifiable {
        let id = UUID()
        let date: Date
        let pathAndQuery: String
        let statusCode: Int?
        let headers: [String: String]
        let networkBytes: Int
        let failure: String?
    }

    private(set) var entries: [Entry] = []

    func record(
        request: URLRequest,
        response: HTTPURLResponse?,
        byteCount: Int,
        failure: String? = nil
    ) {
        let url = request.url
        let pathAndQuery = (url?.path ?? "") + (url?.query.map { "?" + $0 } ?? "")
        // Never retain API keys, Authorization, cookies or arbitrary response headers.
        let allowedHeaders: Set<String> = [
            "cache-control", "vary", "date", "age", "last-modified",
            "x-pagination-page", "x-pagination-limit", "x-pagination-page-count",
            "x-pagination-item-count", "retry-after", "x-ratelimit"
        ]
        let headers = (response?.normalizedHeaders ?? [:]).filter { allowedHeaders.contains($0.key) }
        entries.insert(Entry(
            date: Date(), pathAndQuery: pathAndQuery,
            statusCode: response?.statusCode, headers: headers, networkBytes: byteCount,
            failure: failure
        ), at: 0)
        entries = Array(entries.prefix(30))
    }
}
