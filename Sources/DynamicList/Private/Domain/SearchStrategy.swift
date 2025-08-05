//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// A protocol that defines a customizable search strategy.
///
/// This protocol allows implementing different search strategies for matching a query
/// against a `Searchable` item. By conforming to `SearchStrategy`, developers can define
/// various ways of comparing search queries, such as exact match, partial match, fuzzy search, etc.
public protocol SearchStrategy {
    /// Determines whether a given `Searchable` item matches the search query.
    ///
    /// - Parameters:
    ///   - query: The search string input by the user.
    ///   - item: The `Searchable` item to be evaluated.
    /// - Returns: `true` if the item matches the query based on the implemented strategy, otherwise `false`.
    ///
    /// - Note:
    ///   - Implementations may use different matching techniques such as:
    ///     - Case-insensitive string comparison
    ///     - Diacritic-insensitive search
    ///     - Tokenized search (splitting words and searching for individual terms)
    ///     - Fuzzy matching (e.g., Levenshtein distance for typo tolerance)
    ///
    /// - Example:
    /// ```swift
    /// struct ExactMatchStrategy: SearchStrategy {
    ///     func matches(query: String, in item: Searchable) -> Bool {
    ///         return item.searchKeys.contains { $0.caseInsensitiveCompare(query) == .orderedSame }
    ///     }
    /// }
    /// ```
    func matches(query: String, in item: Searchable) -> Bool
}
