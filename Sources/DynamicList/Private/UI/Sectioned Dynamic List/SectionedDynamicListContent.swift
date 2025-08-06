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
    private let detailContent: ((Item) -> AnyView?)?
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool
    private let searchConfiguration: SearchConfiguration<Item>?
    private let listStyle: ListStyleType

    init(
        viewModel: SectionedDynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: ((Item) -> AnyView?)?,
        errorContent: ((Error) -> AnyView)?,
        skeletonContent: (() -> AnyView)?,
        title: String?,
        navigationBarHidden: Bool,
        searchConfiguration: SearchConfiguration<Item>?,
        listStyle: ListStyleType,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
        self.title = title
        self.navigationBarHidden = navigationBarHidden
        self.searchConfiguration = searchConfiguration
        self.listStyle = listStyle

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
                    ForEach(viewModel.sections) { section in
                        Section {
                            ForEach(section.items) { item in
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
                .modifier(ListStyleModifier(style: listStyle))
                .refreshable {
                    viewModel.refresh()
                }
                .searchable(
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.searchText = $0 },
                    ),
                    placement: searchConfiguration?.placement ?? .automatic,
                    prompt: searchConfiguration?.prompt ?? "Buscar...",
                )
            }
        }
        .navigationDestination(for: Item.self) { item in
            if let detailContent,
               let detailView = detailContent(item)
            {
                detailView
            }
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
