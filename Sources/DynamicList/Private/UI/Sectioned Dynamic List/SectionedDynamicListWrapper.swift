//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
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
	private let sectionFooterContent: ((ListSection<Item>) -> AnyView)?
	private let listConfiguration: ListConfiguration
	private let searchConfiguration: SearchConfiguration<Item>?

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
		_viewModel = State(initialValue: viewModel)
		self.rowContent = rowContent
		self.detailContent = detailContent
		self.errorContent = errorContent
		self.skeletonContent = skeletonContent
		self.sectionFooterContent = sectionFooterContent
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
				sectionFooterContent: sectionFooterContent,
				listConfiguration: listConfiguration,
				searchConfiguration: searchConfiguration,
			)
		}
	}
}
