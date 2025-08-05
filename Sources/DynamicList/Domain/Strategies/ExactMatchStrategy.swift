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
        let queryLower = query.lowercased()
        guard !queryLower.isEmpty else { return true }

        return item.searchKeys.contains { key in
            key.lowercased() == queryLower
        }
    }
}
