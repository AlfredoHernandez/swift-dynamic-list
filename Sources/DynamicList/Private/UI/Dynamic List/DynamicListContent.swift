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
                List(viewModel.items) { item in
                    if let detailContent,
                       let _ = detailContent(item)
                    {
                        NavigationLink(value: item) {
                            rowContent(item)
                                .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
                        }
                    } else {
                        rowContent(item)
                            .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
                    }
                }
                .modifier(ListStyleModifier(style: listConfiguration.style))
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
        .onAppear(perform: viewModel.loadData)
        .navigationDestination(for: Item.self) { item in
            if let detailContent,
               let detailView = detailContent(item)
            {
                detailView
            }
        }
        .navigationTitle(listConfiguration.title ?? "")
        #if os(iOS)
            .navigationBarHidden(listConfiguration.navigationBarHidden)
        #endif
            .searchable(
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 },
                ),
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

    /// ViewModifier to apply list styles
    private struct ListStyleModifier: ViewModifier {
        let style: ListStyleType

        func body(content: Content) -> some View {
            switch style {
            case .automatic:
                content.listStyle(.automatic)
            case .plain:
                content.listStyle(.plain)
            case .inset:
                content.listStyle(.inset)
            #if os(iOS)
            case .grouped:
                content.listStyle(.grouped)
            case .insetGrouped:
                content.listStyle(.insetGrouped)
            #endif
            }
        }
    }
}
