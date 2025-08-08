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
    private let rowContent: (Item) -> AnyView
    private let detailContent: ((Item) -> AnyView?)?
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let listConfiguration: ListConfiguration
    private let searchConfiguration: SearchConfiguration<Item>?
    private let scrollIdentifier = "FIRST_ITEM_IN_LIST"

    init(
        viewModel: DynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: ((Item) -> AnyView?)?,
        errorContent: ((Error) -> AnyView)?,
        skeletonContent: (() -> AnyView)?,
        listConfiguration: ListConfiguration,
        searchConfiguration: SearchConfiguration<Item>?,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.listConfiguration = listConfiguration
        self.searchConfiguration = searchConfiguration

        viewModel.setSearchConfiguration(searchConfiguration)
    }

    var body: some View {
        Group {
            if viewModel.viewState.shouldShowLoading {
                skeletonView
            } else if viewModel.viewState.shouldShowError {
                errorView
            } else {
                itemsList
            }
        }
        .onAppear(perform: viewModel.loadData)
        .navigationDestination(for: Item.self) { item in
            if let detailContent, let detailView = detailContent(item) {
                detailView
            }
        }
        .navigationTitle(listConfiguration.title ?? "")
        #if os(iOS)
            .navigationBarHidden(listConfiguration.navigationBarHidden)
        #endif
            .conditionalSearchable(
                searchConfiguration,
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 },
                ),
            )
    }

    @ViewBuilder
    private var itemsList: some View {
        ScrollToTopButton(itemCount: viewModel.items.count, scrollTarget: scrollIdentifier) {
            listContent
        }
    }

    @ViewBuilder
    private var listContent: some View {
        List(viewModel.items) { item in
            listRow(for: item)
        }
        .modifier(ListStyleModifier(style: listConfiguration.style))
        .refreshable {
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func listRow(for item: Item) -> some View {
        if shouldShowNavigationLink(for: item) {
            NavigationLink(value: item) {
                rowContentWithRedaction(item)
            }
            .id(isFirstItem(item) ? scrollIdentifier : nil)
        } else {
            rowContentWithRedaction(item)
                .id(isFirstItem(item) ? scrollIdentifier : nil)
        }
    }

    private func rowContentWithRedaction(_ item: Item) -> some View {
        rowContent(item)
            .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
    }

    private func shouldShowNavigationLink(for item: Item) -> Bool {
        guard let detailContent else { return false }
        return detailContent(item) != nil
    }

    private func isFirstItem(_ item: Item) -> Bool {
        viewModel.items.firstIndex(of: item) == 0
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
}
