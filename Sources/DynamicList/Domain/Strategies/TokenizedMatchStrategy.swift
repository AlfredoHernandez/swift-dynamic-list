//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Search strategy that performs tokenized matching.
///
/// This strategy splits both the query and search keys into tokens (words) and
/// checks if all query tokens are present in any of the search keys.
public struct TokenizedMatchStrategy: SearchStrategy {
    public init() {}

    public func matches(query: String, in item: Searchable) -> Bool {
        let queryTokens = query.lowercased().split(separator: " ").map(String.init)
        guard !queryTokens.isEmpty else { return true }

        return item.searchKeys.contains { key in
            let keyTokens = key.lowercased().split(separator: " ").map(String.init)
            return queryTokens.allSatisfy { queryToken in
                keyTokens.contains { $0.contains(queryToken) }
            }
        }
    }
}
