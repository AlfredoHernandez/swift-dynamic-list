//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Internal wrapper that provides NavigationStack for standalone lists.
///
/// This component is used internally by the `build()` method to wrap the list content
/// in a NavigationStack. It's not meant to be used directly by consumers.
struct DynamicListWrapper<Item: Identifiable & Hashable>: View {
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: ((Item) -> AnyView?)?
    private let errorContent: ((Error) -> AnyView)?
    private let skeletonContent: (() -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool
    private let searchConfiguration: SearchConfiguration<Item>?
    private let listStyle: ListStyleType

    init(
        viewModel: DynamicListViewModel<Item>,
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
    }

    var body: some View {
        NavigationStack {
            DynamicListContent(
                viewModel: viewModel,
                rowContent: rowContent,
                detailContent: detailContent,
                errorContent: errorContent,
                skeletonContent: skeletonContent,
                title: title,
                navigationBarHidden: navigationBarHidden,
                searchConfiguration: searchConfiguration,
                listStyle: listStyle,
            )
        }
    }
}
