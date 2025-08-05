//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, the content of the detail view,
/// and optionally the content of the error view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
struct DynamicList<Item, RowContent, DetailContent, ErrorContent>: View where Item: Identifiable & Hashable, RowContent: View, DetailContent: View,
    ErrorContent: View
{
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent
    private let errorContent: ((Error) -> ErrorContent)?

    /// Creates a new DynamicList with a view model and custom error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
    }

    /// Creates a new DynamicList with a view model using the default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowError {
                    errorView
                } else if viewModel.viewState.shouldShowLoading {
                    // Show skeleton loading when no items and loading
                    skeletonLoadingView
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

    /// Skeleton loading view when no items are available
    @ViewBuilder
    private var skeletonLoadingView: some View {
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
