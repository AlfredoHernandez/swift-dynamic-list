//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Search strategy that performs exact case-insensitive matching.
///
/// This strategy requires the query to exactly match one of the item's search keys,
/// ignoring case differences.
public struct ExactMatchStrategy: SearchStrategy {
    public init() {}

    public func matches(query: String, in item: Searchable) -> Bool {
        matches(query: query, searchKeys: item.searchKeys)
    }

    private func matches(query: String, searchKeys: [String]) -> Bool {
        let normalizedQuery = normalizeString(query)
        guard !normalizedQuery.isEmpty else { return true }

        return searchKeys.contains { searchKey in
            normalizeString(searchKey) == normalizedQuery
        }
    }
}
