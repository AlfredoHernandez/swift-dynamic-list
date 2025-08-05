//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Searchable Protocol

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

// MARK: - SearchStrategy Protocol

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

// MARK: - Default Search Strategies

/// Default search strategy that performs case-insensitive partial matching.
///
/// This strategy searches for the query string within any of the item's search keys,
/// ignoring case differences. It's the most commonly used search strategy.
public struct PartialMatchStrategy: SearchStrategy {
    public init() {}

    public func matches(query: String, in item: Searchable) -> Bool {
        let queryLower = query.lowercased()
        return item.searchKeys.contains { key in
            key.lowercased().contains(queryLower)
        }
    }
}

/// Search strategy that performs exact case-insensitive matching.
///
/// This strategy requires the query to exactly match one of the item's search keys,
/// ignoring case differences.
public struct ExactMatchStrategy: SearchStrategy {
    public init() {}

    public func matches(query: String, in item: Searchable) -> Bool {
        let queryLower = query.lowercased()
        return item.searchKeys.contains { key in
            key.lowercased() == queryLower
        }
    }
}

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

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, the content of the detail view,
/// and optionally the content of the error view and skeleton view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
struct DynamicList<Item, RowContent, DetailContent, ErrorContent, SkeletonContent>: View where Item: Identifiable & Hashable, RowContent: View,
    DetailContent: View,
    ErrorContent: View, SkeletonContent: View
{
    @State private var viewModel: DynamicListViewModel<Item>
    @State private var searchText = ""

    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent
    private let errorContent: ((Error) -> ErrorContent)?
    private let skeletonContent: (() -> SkeletonContent)?
    private let searchPrompt: String?
    private let searchPredicate: ((Item, String) -> Bool)?
    private let searchStrategy: SearchStrategy?

    /// Creates a new DynamicList with a view model, custom error view, and custom skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    ///   - searchPrompt: Optional prompt text for the search field.
    ///   - searchPredicate: Optional custom search predicate for filtering items.
    ///   - searchStrategy: Optional search strategy for Searchable items.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
    }

    /// Creates a new DynamicList with a view model, custom skeleton view, and default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    ///   - searchPrompt: Optional prompt text for the search field.
    ///   - searchPredicate: Optional custom search predicate for filtering items.
    ///   - searchStrategy: Optional search strategy for Searchable items.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        self.skeletonContent = skeletonContent
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
    }

    /// Creates a new DynamicList with a view model using the default error view and default skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - searchPrompt: Optional prompt text for the search field.
    ///   - searchPredicate: Optional custom search predicate for filtering items.
    ///   - searchStrategy: Optional search strategy for Searchable items.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
    ) where ErrorContent == DefaultErrorView, SkeletonContent == DefaultSkeletonView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        skeletonContent = nil
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowError {
                    errorView
                } else if viewModel.viewState.shouldShowLoading {
                    // Show skeleton loading when no items and loading
                    skeletonView
                } else {
                    // Show normal list with items
                    List(filteredItems) { item in
                        NavigationLink(value: item) {
                            rowContent(item)
                                .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
                        }
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
            .searchable(
                text: $searchText,
                prompt: searchPrompt ?? "Buscar...",
            )
        }
    }

    /// Filtered items based on search text
    private var filteredItems: [Item] {
        guard !searchText.isEmpty else {
            return viewModel.viewState.items
        }

        return viewModel.viewState.items.filter { item in
            if let searchPredicate {
                return searchPredicate(item, searchText)
            } else if let searchableItem = item as? Searchable {
                let strategy = searchStrategy ?? PartialMatchStrategy()
                return strategy.matches(query: searchText, in: searchableItem)
            } else {
                // Fallback: try to use description if available
                return String(describing: item).lowercased().contains(searchText.lowercased())
            }
        }
    }

    /// Skeleton view - uses custom content if provided, otherwise default
    @ViewBuilder
    private var skeletonView: some View {
        if let skeletonContent {
            skeletonContent()
        } else {
            DefaultSkeletonView()
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorContent,
           let error = viewModel.viewState.error
        {
            errorContent(error)
        } else if let error = viewModel.viewState.error {
            DefaultErrorView(error: error)
        }
    }
}
