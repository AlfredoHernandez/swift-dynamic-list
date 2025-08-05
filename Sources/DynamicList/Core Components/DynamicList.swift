//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, the content of the detail view,
/// and optionally the content of the error view and skeleton view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
struct DynamicList<Item, RowContent, DetailContent, ErrorContent, SkeletonContent>: View where Item: Identifiable & Hashable, RowContent: View,
    DetailContent: View,
    ErrorContent: View, SkeletonContent: View
{
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent
    private let errorContent: ((Error) -> ErrorContent)?
    private let skeletonContent: (() -> SkeletonContent)?

    /// Creates a new DynamicList with a view model, custom error view, and custom skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
    }

    /// Creates a new DynamicList with a view model, custom skeleton view, and default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        self.skeletonContent = skeletonContent
    }

    /// Creates a new DynamicList with a view model using the default error view and default skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) where ErrorContent == DefaultErrorView, SkeletonContent == DefaultSkeletonView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        skeletonContent = nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowError {
                    errorView
                } else if viewModel.viewState.shouldShowLoading {
                    // Show skeleton loading when no items and loading
                    skeletonView
                } else {
                    // Show normal list with items
                    List(viewModel.viewState.items) { item in
                        NavigationLink(value: item) {
                            rowContent(item)
                                .redacted(reason: viewModel.viewState.isLoading ? .placeholder : [])
                        }
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }

    /// Skeleton view - uses custom content if provided, otherwise default
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

/// A view that displays a sectioned list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, the content of the detail view,
/// and optionally the content of the error view and skeleton view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
struct SectionedDynamicList<Item, RowContent, DetailContent, ErrorContent, SkeletonContent>: View where Item: Identifiable & Hashable, RowContent: View,
    DetailContent: View,
    ErrorContent: View, SkeletonContent: View
{
    @State private var viewModel: SectionedDynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent
    private let errorContent: ((Error) -> ErrorContent)?
    private let skeletonContent: (() -> SkeletonContent)?

    /// Creates a new SectionedDynamicList with a view model, custom error view, and custom skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the sections to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    init(
        viewModel: SectionedDynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.skeletonContent = skeletonContent
    }

    /// Creates a new SectionedDynamicList with a view model, custom skeleton view, and default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the sections to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - skeletonContent: A view builder that creates the skeleton view when loading with no items.
    init(
        viewModel: SectionedDynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder skeletonContent: @escaping () -> SkeletonContent,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        self.skeletonContent = skeletonContent
    }

    /// Creates a new SectionedDynamicList with a view model using the default error view and default skeleton view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the sections to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    init(
        viewModel: SectionedDynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) where ErrorContent == DefaultErrorView, SkeletonContent == DefaultSkeletonView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
        skeletonContent = nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowError {
                    errorView
                } else if viewModel.viewState.shouldShowLoading {
                    // Show skeleton loading when no items and loading
                    skeletonView
                } else {
                    // Show sectioned list with items
                    List {
                        ForEach(viewModel.viewState.sections) { section in
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
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }

    /// Skeleton view - uses custom content if provided, otherwise default
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

// MARK: - Default Skeleton View

/// Default skeleton view for loading states
struct DefaultSkeletonView: View {
    var body: some View {
        List(0 ..< 10, id: \.self) { _ in
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .frame(maxWidth: .infinity)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .frame(maxWidth: .infinity * 0.7)
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .redacted(reason: .placeholder)
    }
}

/// Default skeleton view for sectioned loading states
struct DefaultSectionedSkeletonView: View {
    var body: some View {
        List {
            ForEach(0 ..< 3, id: \.self) { sectionIndex in
                Section {
                    ForEach(0 ..< (sectionIndex + 2), id: \.self) { _ in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 16)
                                    .frame(maxWidth: .infinity)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                    .frame(maxWidth: .infinity * 0.7)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity * 0.5)
                }
            }
        }
        .redacted(reason: .placeholder)
    }
}
