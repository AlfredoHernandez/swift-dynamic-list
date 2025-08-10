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
    private let unifiedContent: UnifiedDynamicListContent<Item>

    init(
        viewModel: DynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: ((Item) -> AnyView?)?,
        errorContent: ((Error) -> AnyView)?,
        skeletonContent: (() -> AnyView)?,
        listConfiguration: ListConfiguration,
        searchConfiguration: SearchConfiguration<Item>?,
    ) {
        let listType = ListType.simple(items: viewModel.items)
        unifiedContent = UnifiedDynamicListContent(
            viewModel: viewModel,
            listType: listType,
            rowContent: rowContent,
            detailContent: detailContent,
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            listConfiguration: listConfiguration,
            searchConfiguration: searchConfiguration,
        )
    }

    var body: some View {
        unifiedContent
    }
}
