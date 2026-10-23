import Foundation

public struct Pagination: Equatable, Sendable {
    public let page: Int
    public let limit: Int
    public let pageCount: Int
    public let itemCount: Int

    public var hasNextPage: Bool { page < pageCount }

    public init(page: Int,
                limit: Int,
                pageCount: Int,
                itemCount: Int) {
        self.page = page
        self.limit = limit
        self.pageCount = pageCount
        self.itemCount = itemCount
    }
}
