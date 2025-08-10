//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Internal component that renders the actual dynamic list content (both simple and sectioned).
///
/// This component handles the core list rendering logic including loading states,
/// error handling, and navigation. It's used by both `DynamicListWrapper` and
/// `SectionedDynamicListWrapper` and the `buildWithoutNavigation()` methods.
struct UnifiedDynamicListContent<Item: Identifiable & Hashable>: View {
    @State private var viewModel: AnyDynamicListViewModel<Item>

    private let listType: ListType<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: ((Item) -> AnyView?)?
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let listConfiguration: ListConfiguration
    private let searchConfiguration: SearchConfiguration<Item>?
    private let scrollIdentifier = "FIRST_ITEM_IN_LIST"

    init<V: DynamicListViewModelProtocol>(
        viewModel: V,
        listType: ListType<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: ((Item) -> AnyView?)?,
        errorContent: ((Error) -> AnyView)?,
        skeletonContent: (() -> AnyView)?,
        listConfiguration: ListConfiguration,
        searchConfiguration: SearchConfiguration<Item>?,
    ) where V.Item == Item {
        _viewModel = State(initialValue: AnyDynamicListViewModel(viewModel))
        self.listType = listType
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
            if viewModel.viewState.shouldShowLoading(showSkeletonOnRefresh: listConfiguration.showSkeletonOnRefresh) {
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
        .conditionalNavigationBarHidden(listConfiguration.navigationBarHidden)
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
        switch listType {
        case .simple:
            ScrollToTopButton(itemCount: listType.allItems.count, scrollTarget: scrollIdentifier) {
                simpleListContent
            }
        case .sectioned:
            sectionedListContent
        }
    }

    @ViewBuilder
    private var simpleListContent: some View {
        List(listType.allItems) { item in
            listRow(for: item)
        }
        .modifier(ListStyleModifier(style: listConfiguration.style))
        .refreshable {
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private var sectionedListContent: some View {
        List {
            // Use dynamic sections from viewModel's viewState instead of static listType
            if let sectionedState = viewModel.viewState as? SectionedListViewState<Item> {
                ForEach(sectionedState.sections) { section in
                    Section {
                        ForEach(section.items) { item in
                            listRow(for: item)
                        }
                    } header: {
                        if let title = section.title {
                            Text(title)
                        }
                    } footer: {
                        if let footer = section.footer {
                            Text(footer)
                        }
                    }
                }
            }
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
        // Use dynamic sections from viewModel's viewState
        switch listType {
        case .simple:
            return listType.allItems.firstIndex(of: item) == 0
        case .sectioned:
            if let sectionedState = viewModel.viewState as? SectionedListViewState<Item> {
                return sectionedState.sections.first?.items.firstIndex(of: item) == 0
            }
            return false
        }
    }

    @ViewBuilder
    private var skeletonView: some View {
        if let skeletonContent {
            skeletonContent()
        } else {
            switch listType {
            case .simple:
                DefaultSkeletonView()
            case .sectioned:
                DefaultSectionedSkeletonView()
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorContent, let error = viewModel.viewState.error {
            errorContent(error)
        } else if let error = viewModel.viewState.error {
            DefaultErrorView(error: error)
        }
    }
}
