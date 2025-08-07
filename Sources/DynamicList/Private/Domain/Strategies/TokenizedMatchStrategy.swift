//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Search strategy that performs tokenized matching.
///
/// This strategy splits both the query and search keys into tokens (words) and
/// checks if all query tokens are present in any of the search keys.
///
/// ## How it works
///
/// 1. The query is split into individual tokens (words)
/// 2. Each search key is normalized (lowercase, trimmed)
/// 3. For each query token, it checks if it's contained in any search key
/// 4. Returns true only if ALL query tokens are found
///
/// ## Examples
///
/// **Example 1: Single word query**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ✅ true (found in name)
/// strategy.matches(query: "engineer", in: user) // ✅ true (found in role)
/// strategy.matches(query: "xyz", in: user) // ❌ false (not found)
/// ```
///
/// **Example 2: Multiple word query**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "john smith", in: user) // ✅ true (both tokens found in name)
/// strategy.matches(query: "software engineer", in: user) // ✅ true (both tokens found in role)
/// strategy.matches(query: "john engineer", in: user) // ✅ true (john in name, engineer in role)
/// strategy.matches(query: "john xyz", in: user) // ❌ false (xyz not found anywhere)
/// ```
///
/// **Example 3: Case insensitive matching**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "JOHN.SMITH@EXAMPLE.COM",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "JOHN", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "john smith", in: user) // ✅ true (both tokens found)
/// strategy.matches(query: "SOFTWARE ENGINEER", in: user) // ✅ true (both tokens found)
/// ```
///
/// **Example 4: Partial matches within tokens**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ✅ true (exact match in name)
/// strategy.matches(query: "jo", in: user) // ✅ true (partial match in name)
/// strategy.matches(query: "engineer", in: user) // ✅ true (exact match in role)
/// strategy.matches(query: "eng", in: user) // ✅ true (partial match in role)
/// ```
///
/// **Example 5: Empty and whitespace queries**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "", in: user) // ✅ true (empty query always matches)
/// strategy.matches(query: "   ", in: user) // ✅ true (whitespace-only query always matches)
/// ```
///
/// **Example 6: Special characters and punctuation**
/// ```swift
/// let user = SearchableUser(
///     name: "John-Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = TokenizedMatchStrategy()
///
/// strategy.matches(query: "john smith", in: user) // ✅ true (ignores hyphens and dots)
/// strategy.matches(query: "john.smith", in: user) // ✅ true (ignores dots)
/// strategy.matches(query: "john@smith", in: user) // ✅ true (ignores @ symbol)
/// ```
///
/// ## Use Cases
///
/// This strategy is ideal for:
/// - **Natural language search**: Users can type multiple words in any order
/// - **Flexible matching**: Partial matches within words are supported
/// - **Cross-field search**: Tokens can be found in different search keys
/// - **User-friendly search**: Handles common variations in user input
///
/// ## Comparison with other strategies
///
/// - **PartialMatchStrategy**: Only requires one token to match
/// - **ExactMatchStrategy**: Requires exact word boundaries
/// - **TokenizedMatchStrategy**: Requires ALL tokens to match (most restrictive)
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
