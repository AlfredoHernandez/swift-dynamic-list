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
        let queryLower = query.lowercased()
        guard !queryLower.isEmpty else { return true }

        return item.searchKeys.contains { key in
            key.lowercased().contains(queryLower)
        }
    }
}
