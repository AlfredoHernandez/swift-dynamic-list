//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Internal component that renders the actual sectioned list content.
///
/// This component handles the core sectioned list rendering logic including loading states,
/// error handling, and navigation. It's used by both `SectionedDynamicListWrapper` and
/// the `buildWithoutNavigation()` method.
struct SectionedDynamicListContent<Item: Identifiable & Hashable>: View {
    @State private var viewModel: SectionedDynamicListViewModel<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: (Item) -> AnyView
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool
    private let searchConfiguration: SearchConfiguration<Item>?

    init(
        viewModel: SectionedDynamicListViewModel<Item>,
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

        // Configure search in the view model
        viewModel.setSearchConfiguration(searchConfiguration)
    }

    var body: some View {
        Group {
            if viewModel.viewState.shouldShowLoading {
                skeletonView
            } else if viewModel.viewState.shouldShowError {
                errorView
            } else {
                List {
                    ForEach(viewModel.filteredSectionsList) { section in
                        Section {
                            ForEach(section.items) { item in
                                NavigationLink(value: item) {
                                    rowContent(item)
                                        .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
                                }
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
                .refreshable {
                    viewModel.refresh()
                }
                .searchable(
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { newValue in
                            viewModel.updateSearchText(newValue)
                        },
                    ),
                    placement: searchConfiguration?.placement ?? .automatic,
                    prompt: searchConfiguration?.prompt ?? "Buscar...",
                )
            }
        }
        .navigationDestination(for: Item.self) { item in
            detailContent(item)
        }
        .navigationTitle(title ?? "")
        #if os(iOS)
            .navigationBarHidden(navigationBarHidden)
        #endif
    }

    @ViewBuilder
    private var skeletonView: some View {
        if let skeletonContent {
            skeletonContent()
        } else {
            DefaultSectionedSkeletonView()
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
