//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - SectionedDynamicList Wrapper

/// Internal wrapper that provides NavigationStack for standalone sectioned lists.
///
/// This component is used internally by the `build()` method to wrap the sectioned list content
/// in a NavigationStack. It's not meant to be used directly by consumers.
struct SectionedDynamicListWrapper<Item: Identifiable & Hashable>: View {
    @State private var viewModel: SectionedDynamicListViewModel<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: ((Item) -> AnyView?)?
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let listConfiguration: ListConfiguration
    private let searchConfiguration: SearchConfiguration<Item>?

    init(
        viewModel: SectionedDynamicListViewModel<Item>,
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
    }

    var body: some View {
        NavigationStack {
            SectionedDynamicListContent(
                viewModel: viewModel,
                rowContent: rowContent,
                detailContent: detailContent,
                errorContent: errorContent,
                skeletonContent: skeletonContent,
                listConfiguration: listConfiguration,
                searchConfiguration: searchConfiguration,
            )
        }
    }
}
