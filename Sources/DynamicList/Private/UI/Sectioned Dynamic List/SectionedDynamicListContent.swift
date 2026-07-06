//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Internal component that renders the actual sectioned list content.
///
/// This component handles the core sectioned list rendering logic including loading states,
/// error handling, and navigation. It's used by both `SectionedDynamicListWrapper` and
/// the `buildWithoutNavigation()` method.
struct SectionedDynamicListContent<Item: Identifiable & Hashable>: View {
	private let unifiedContent: UnifiedDynamicListContent<Item>

	init(
		viewModel: SectionedDynamicListViewModel<Item>,
		rowContent: @escaping (Item) -> AnyView,
		detailContent: ((Item) -> AnyView?)?,
		errorContent: ((Error) -> AnyView)?,
		skeletonContent: (() -> AnyView)?,
		sectionFooterContent: ((ListSection<Item>) -> AnyView)? = nil,
		listConfiguration: ListConfiguration,
		searchConfiguration: SearchConfiguration<Item>?,
	) {
		let listType = ListType.sectioned(sections: viewModel.sections)
		unifiedContent = UnifiedDynamicListContent(
			viewModel: viewModel,
			listType: listType,
			rowContent: rowContent,
			detailContent: detailContent,
			errorContent: errorContent,
			skeletonContent: skeletonContent,
			sectionFooterContent: sectionFooterContent,
			listConfiguration: listConfiguration,
			searchConfiguration: searchConfiguration,
		)
	}

	var body: some View {
		unifiedContent
	}
}
