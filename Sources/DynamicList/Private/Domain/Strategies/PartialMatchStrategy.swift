//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Default search strategy that performs case-insensitive partial matching.
///
/// This strategy searches for the query string within any of the item's search keys,
/// ignoring case differences. It's the most commonly used search strategy.
public struct PartialMatchStrategy: SearchStrategy {
    public init() {}

    public func matches(query: String, in item: Searchable) -> Bool {
        matches(query: query, searchKeys: item.searchKeys)
    }

    func matches(query: String, searchKeys: [String]) -> Bool {
        let normalizedQuery = normalizeString(query)
        guard !normalizedQuery.isEmpty else { return true }

        return searchKeys.contains { searchKey in
            normalizeString(searchKey).contains(normalizedQuery)
        }
    }
}
