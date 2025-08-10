//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// A protocol that defines the essential requirements for searchable items.
///
/// Conforming types must provide at least one search key that will be used in search operations.
/// This allows objects to be indexed and queried efficiently.
///
/// The protocol also conforms to `Sendable`, making it safe for use in concurrent environments.
public protocol Searchable: Sendable {
    /// A list of search keys associated with the item.
    ///
    /// - These keys represent the textual data that will be used for searching.
    /// - Typically, they can include names, titles, descriptions, or any relevant searchable content.
    /// - Multiple keys allow a single item to be found through different queries.
    ///
    /// - Example:
    /// ```swift
    /// struct Product: Searchable {
    ///     let title: String
    ///     let tags: [String]
    ///
    ///     var searchKeys: [String] {
    ///         return [title] + tags
    ///     }
    /// }
    /// ```
    var searchKeys: [String] { get }
}
