//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Search strategy that performs exact case-insensitive matching.
///
/// This strategy requires the query to exactly match one of the item's search keys,
/// ignoring case differences. It's the most restrictive search strategy.
///
/// ## How it works
///
/// 1. The query is normalized (lowercase, trimmed)
/// 2. Each search key is normalized (lowercase, trimmed)
/// 3. Returns true only if the normalized query exactly equals any normalized search key
/// 4. Empty queries always return true
///
/// ## Examples
///
/// **Example 1: Exact matches**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "john smith", in: user) // ✅ true (exact match with name)
/// strategy.matches(query: "software engineer", in: user) // ✅ true (exact match with role)
/// strategy.matches(query: "john", in: user) // ❌ false (partial match, not exact)
/// strategy.matches(query: "engineer", in: user) // ❌ false (partial match, not exact)
/// ```
///
/// **Example 2: Case insensitive matching**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "JOHN.SMITH@EXAMPLE.COM",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "JOHN SMITH", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "john smith", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "John Smith", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "SOFTWARE ENGINEER", in: user) // ✅ true (case insensitive)
/// ```
///
/// **Example 3: Whitespace handling**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "  john smith  ", in: user) // ✅ true (whitespace trimmed)
/// strategy.matches(query: "john  smith", in: user) // ✅ true (multiple spaces normalized)
/// strategy.matches(query: "Software  Engineer", in: user) // ✅ true (multiple spaces normalized)
/// ```
///
/// **Example 4: Empty and whitespace queries**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "", in: user) // ✅ true (empty query always matches)
/// strategy.matches(query: "   ", in: user) // ✅ true (whitespace-only query always matches)
/// ```
///
/// **Example 5: No partial matches**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ❌ false (partial match)
/// strategy.matches(query: "smith", in: user) // ❌ false (partial match)
/// strategy.matches(query: "software", in: user) // ❌ false (partial match)
/// strategy.matches(query: "engineer", in: user) // ❌ false (partial match)
/// strategy.matches(query: "john smith", in: user) // ✅ true (exact match)
/// ```
///
/// **Example 6: Special characters and punctuation**
/// ```swift
/// let user = SearchableUser(
///     name: "John-Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = ExactMatchStrategy()
///
/// strategy.matches(query: "john-smith", in: user) // ✅ true (exact match with hyphens)
/// strategy.matches(query: "john.smith@example.com", in: user) // ✅ true (exact match with dots and @)
/// strategy.matches(query: "john smith", in: user) // ❌ false (no hyphens in query)
/// ```
///
/// ## Use Cases
///
/// This strategy is ideal for:
/// - **Precise search**: When you need exact matches only
/// - **Tag-based search**: Matching specific tags or categories
/// - **ID-based search**: Finding items by exact identifiers
/// - **Strict filtering**: When partial matches are not desired
/// - **Data validation**: Ensuring exact data matches
///
/// ## Comparison with other strategies
///
/// - **PartialMatchStrategy**: Allows partial matches within search keys
/// - **TokenizedMatchStrategy**: Splits query into tokens and requires all to match
/// - **ExactMatchStrategy**: Requires exact string match (most restrictive)
///
/// ## When to use
///
/// Use this strategy when:
/// - You want to prevent false positives from partial matches
/// - Users should type the exact search term
/// - You're searching for specific codes, IDs, or tags
/// - You need precise control over what constitutes a match
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
