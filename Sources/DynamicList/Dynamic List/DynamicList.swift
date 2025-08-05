//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

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
    private let searchPlacement: SearchFieldPlacement

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
    ///   - searchPlacement: Optional placement configuration for the search field.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
        searchPlacement: SearchFieldPlacement = .automatic,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
        self.searchPlacement = searchPlacement
    }

    /// Creates a new DynamicList with a view model, custom skeleton view, and default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    ///   - searchPrompt: Optional prompt text for the search field.
    ///   - searchPrompt: Optional prompt text for the search field.
    ///   - searchPredicate: Optional custom search predicate for filtering items.
    ///   - searchStrategy: Optional search strategy for Searchable items.
    ///   - searchPlacement: Optional placement configuration for the search field.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
        searchPlacement: SearchFieldPlacement = .automatic,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        self.skeletonContent = skeletonContent
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
        self.searchPlacement = searchPlacement
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
    ///   - searchPlacement: Optional placement configuration for the search field.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        searchPrompt: String? = nil,
        searchPredicate: ((Item, String) -> Bool)? = nil,
        searchStrategy: SearchStrategy? = nil,
        searchPlacement: SearchFieldPlacement = .automatic,
    ) where ErrorContent == DefaultErrorView, SkeletonContent == DefaultSkeletonView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        skeletonContent = nil
        self.searchPrompt = searchPrompt
        self.searchPredicate = searchPredicate
        self.searchStrategy = searchStrategy
        self.searchPlacement = searchPlacement
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
                placement: searchPlacement,
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
