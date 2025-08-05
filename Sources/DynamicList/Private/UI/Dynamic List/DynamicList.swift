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
    private let searchConfiguration: SearchConfiguration<Item>?

    /// Creates a new DynamicList with a view model, custom error view, and custom skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    ///   - searchConfiguration: Optional search configuration for the list.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchConfiguration: SearchConfiguration<Item>? = nil,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.searchConfiguration = searchConfiguration
    }

    /// Creates a new DynamicList with a view model, custom skeleton view, and default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    ///   - searchConfiguration: Optional search configuration for the list.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
        searchConfiguration: SearchConfiguration<Item>? = nil,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        self.skeletonContent = skeletonContent
        self.searchConfiguration = searchConfiguration
    }

    /// Creates a new DynamicList with a view model using the default error view and default skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - searchConfiguration: Optional search configuration for the list.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        searchConfiguration: SearchConfiguration<Item>? = nil,
    ) where ErrorContent == DefaultErrorView, SkeletonContent == DefaultSkeletonView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        skeletonContent = nil
        self.searchConfiguration = searchConfiguration
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
                placement: searchConfiguration?.placement ?? .automatic,
                prompt: searchConfiguration?.prompt ?? "Buscar...",
            )
        }
    }

    /// Filtered items based on search text
    private var filteredItems: [Item] {
        guard !searchText.isEmpty else {
            return viewModel.viewState.items
        }

        return viewModel.viewState.items.filter { item in
            if let searchConfiguration {
                if let predicate = searchConfiguration.predicate {
                    return predicate(item, searchText)
                } else if let searchableItem = item as? Searchable {
                    let strategy = searchConfiguration.strategy ?? PartialMatchStrategy()
                    return strategy.matches(query: searchText, in: searchableItem)
                }
            }

            // Fallback: try to use description if available
            return String(describing: item).lowercased().contains(searchText.lowercased())
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
