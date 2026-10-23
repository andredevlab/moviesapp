import Foundation

public struct PageRequest: Equatable, Sendable {
    public enum ValidationError: Error, Equatable, Sendable {
        case invalidPage
        case invalidLimit
    }

    public let page: Int
    public let limit: Int

    public init(page: Int, limit: Int) throws {
        guard page >= 1 else { throw ValidationError.invalidPage }
        guard limit > 0 else { throw ValidationError.invalidLimit }
        self.page = page
        self.limit = limit
    }
}
