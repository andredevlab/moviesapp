import Foundation
import Networking

struct MockHTTPRequest: HTTPRequest {
    let method: String
    let url: URL
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?
}
