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
        matches(query: query, searchKeys: item.searchKeys)
    }

    private func matches(query: String, searchKeys: [String]) -> Bool {
        let queryTokens = tokenizeString(query)
        guard !queryTokens.isEmpty else { return true }

        return queryTokens.allSatisfy { queryToken in
            searchKeys.contains { searchKey in
                normalizeString(searchKey).contains(queryToken)
            }
        }
    }
}
