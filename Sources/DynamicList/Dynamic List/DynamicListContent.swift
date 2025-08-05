//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Internal component that renders the actual list content.
///
/// This component handles the core list rendering logic including loading states,
/// error handling, and navigation. It's used by both `DynamicListWrapper` and
/// the `buildWithoutNavigation()` method.
struct DynamicListContent<Item: Identifiable & Hashable>: View {
    @State private var viewModel: DynamicListViewModel<Item>
    @State private var searchText = ""
    private let rowContent: (Item) -> AnyView
    private let detailContent: (Item) -> AnyView
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool
    private let searchConfiguration: SearchConfiguration<Item>?

    init(
        viewModel: DynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: @escaping (Item) -> AnyView,
        errorContent: ((Error) -> AnyView)?,
        skeletonContent: (() -> AnyView)?,
        title: String?,
        navigationBarHidden: Bool,
        searchConfiguration: SearchConfiguration<Item>?,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.title = title
        self.navigationBarHidden = navigationBarHidden
        self.searchConfiguration = searchConfiguration
    }

    var body: some View {
        Group {
            if viewModel.viewState.shouldShowLoading {
                skeletonView
            } else if viewModel.viewState.shouldShowError {
                errorView
            } else {
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
        .navigationTitle(title ?? "")
        #if os(iOS)
            .navigationBarHidden(navigationBarHidden)
        #endif
            .searchable(
                text: $searchText,
                placement: searchConfiguration?.placement ?? .automatic,
                prompt: searchConfiguration?.prompt ?? "Buscar...",
            )
    }

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
}
