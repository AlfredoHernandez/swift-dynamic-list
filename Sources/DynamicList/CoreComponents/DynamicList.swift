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
public struct DynamicList<Item, RowContent, DetailContent, ErrorContent>: View where Item: Identifiable & Hashable, RowContent: View, DetailContent: View,
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
    public init(
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
    public init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowLoading {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.viewState.shouldShowError {
                    errorView
                } else {
                    List(viewModel.viewState.items) { item in
                        NavigationLink(value: item) { rowContent(item) }
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
