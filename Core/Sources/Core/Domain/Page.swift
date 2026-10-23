import Foundation

public struct Page<Element: Sendable>: Sendable {
    public let items: [Element]
    public let pagination: Pagination

    public init(items: [Element], pagination: Pagination) {
        self.items = items
        self.pagination = pagination
    }
}

extension Page: Equatable where Element: Equatable {}
