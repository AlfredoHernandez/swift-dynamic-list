//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Default search strategy that performs case-insensitive partial matching.
///
/// This strategy searches for the query string within any of the item's search keys,
/// ignoring case differences. It's the most commonly used search strategy and provides
/// a good balance between flexibility and precision.
///
/// ## How it works
///
/// 1. The query is normalized (lowercase, trimmed)
/// 2. Each search key is normalized (lowercase, trimmed)
/// 3. Returns true if the normalized query is contained within any normalized search key
/// 4. Empty queries always return true
///
/// ## Examples
///
/// **Example 1: Basic partial matching**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ✅ true (found in name)
/// strategy.matches(query: "smith", in: user) // ✅ true (found in name)
/// strategy.matches(query: "software", in: user) // ✅ true (found in role)
/// strategy.matches(query: "engineer", in: user) // ✅ true (found in role)
/// strategy.matches(query: "xyz", in: user) // ❌ false (not found anywhere)
/// ```
///
/// **Example 2: Case insensitive matching**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "JOHN.SMITH@EXAMPLE.COM",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "JOHN", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "john", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "John", in: user) // ✅ true (case insensitive)
/// strategy.matches(query: "SOFTWARE", in: user) // ✅ true (case insensitive)
/// ```
///
/// **Example 3: Partial matches within words**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "jo", in: user) // ✅ true (partial match in "john")
/// strategy.matches(query: "oh", in: user) // ✅ true (partial match in "john")
/// strategy.matches(query: "eng", in: user) // ✅ true (partial match in "engineer")
/// strategy.matches(query: "eer", in: user) // ✅ true (partial match in "engineer")
/// strategy.matches(query: "xyz", in: user) // ❌ false (no partial match)
/// ```
///
/// **Example 4: Whitespace handling**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "  john  ", in: user) // ✅ true (whitespace trimmed)
/// strategy.matches(query: "  software  ", in: user) // ✅ true (whitespace trimmed)
/// strategy.matches(query: "   ", in: user) // ✅ true (whitespace-only query always matches)
/// ```
///
/// **Example 5: Empty queries**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
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
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ✅ true (found in name)
/// strategy.matches(query: "smith", in: user) // ✅ true (found in name)
/// strategy.matches(query: "john.smith", in: user) // ✅ true (found in email)
/// strategy.matches(query: "example.com", in: user) // ✅ true (found in email)
/// strategy.matches(query: "@example", in: user) // ✅ true (found in email)
/// ```
///
/// **Example 7: Cross-field matching**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "john", in: user) // ✅ true (found in name and email)
/// strategy.matches(query: "smith", in: user) // ✅ true (found in name and email)
/// strategy.matches(query: "software", in: user) // ✅ true (found in role)
/// strategy.matches(query: "engineer", in: user) // ✅ true (found in role)
/// ```
///
/// **Example 8: Edge cases**
/// ```swift
/// let user = SearchableUser(
///     name: "John Smith",
///     email: "john.smith@example.com",
///     role: "Software Engineer"
/// )
/// let strategy = PartialMatchStrategy()
///
/// strategy.matches(query: "j", in: user) // ✅ true (single character match)
/// strategy.matches(query: "a", in: user) // ✅ true (found in "example.com")
/// strategy.matches(query: "z", in: user) // ❌ false (not found anywhere)
/// strategy.matches(query: "johnsmith", in: user) // ❌ false (no spaces in query)
/// ```
///
/// ## Use Cases
///
/// This strategy is ideal for:
/// - **General search**: Most common use case for user-friendly search
/// - **Flexible matching**: When you want to find items even with partial input
/// - **User-friendly search**: Handles typos and partial typing well
/// - **Cross-field search**: Finds matches across multiple search keys
/// - **Incremental search**: Works well as users type
///
/// ## Comparison with other strategies
///
/// - **ExactMatchStrategy**: Requires exact string match (more restrictive)
/// - **TokenizedMatchStrategy**: Splits query into tokens and requires all to match
/// - **PartialMatchStrategy**: Allows partial matches within search keys (most flexible)
///
/// ## When to use
///
/// Use this strategy when:
/// - You want to provide a user-friendly search experience
/// - Users might type partial words or make typos
/// - You want to find items even with incomplete search terms
/// - You need flexible matching across multiple fields
/// - This is your default search strategy for most use cases
///
/// ## Performance considerations
///
/// - This strategy is generally fast for small to medium datasets
/// - For large datasets, consider using more restrictive strategies
/// - The case-insensitive matching adds minimal overhead
/// - Empty queries are handled efficiently (always return true)
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
