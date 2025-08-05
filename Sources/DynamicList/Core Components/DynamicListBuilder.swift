//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DynamicList Builder

/// A builder class that simplifies the creation of DynamicList instances
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public final class DynamicListBuilder<Item: Identifiable & Hashable> {
    private var items: [Item] = []
    private var publisher: AnyPublisher<[Item], Error>?
    private var rowContent: ((Item) -> AnyView)?
    private var detailContent: ((Item) -> AnyView)?
    private var errorContent: ((Error) -> AnyView)?
    private var title: String?
    private var navigationBarHidden: Bool = false

    public init() {}

    // MARK: - Data Source Configuration

    /// Sets static items for the list
    @discardableResult
    public func items(_ items: [Item]) -> Self {
        self.items = items
        return self
    }

    /// Sets a Combine publisher as the data source
    @discardableResult
    public func publisher(_ publisher: AnyPublisher<[Item], Error>) -> Self {
        self.publisher = publisher
        return self
    }

    /// Sets a simple publisher that emits a single array of items
    @discardableResult
    public func simplePublisher(_ items: [Item]) -> Self {
        publisher = Just(items)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        return self
    }

    /// Sets a publisher that simulates loading with delay
    @discardableResult
    public func simulatedPublisher(_ items: [Item], delay: TimeInterval = 1.0) -> Self {
        publisher = Just(items)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        return self
    }

    // MARK: - UI Configuration

    /// Sets the row content builder
    @discardableResult
    public func rowContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        rowContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets the detail content builder
    @discardableResult
    public func detailContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        detailContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets a custom error view
    @discardableResult
    public func errorContent(@ViewBuilder _ content: @escaping (Error) -> some View) -> Self {
        errorContent = { error in
            AnyView(content(error))
        }
        return self
    }

    /// Sets the navigation title
    @discardableResult
    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    /// Hides the navigation bar
    @discardableResult
    public func hideNavigationBar() -> Self {
        navigationBarHidden = true
        return self
    }

    // MARK: - Build Methods

    /// Builds a DynamicList with the configured settings
    @MainActor
    public func build() -> some View {
        let viewModel: DynamicListViewModel<Item> = if let publisher {
            DynamicListViewModel(publisher: publisher, initialItems: items)
        } else {
            DynamicListViewModel(items: items)
        }

        return DynamicListWrapper(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent ?? { item in
                AnyView(DefaultDetailView(item: item))
            },
            errorContent: errorContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
        )
    }

    /// Builds a DynamicList without NavigationStack (for use within existing navigation)
    @MainActor
    public func buildWithoutNavigation() -> some View {
        let viewModel: DynamicListViewModel<Item> = if let publisher {
            DynamicListViewModel(publisher: publisher, initialItems: items)
        } else {
            DynamicListViewModel(items: items)
        }

        return DynamicListContent(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent ?? { item in
                AnyView(DefaultDetailView(item: item))
            },
            errorContent: errorContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
        )
    }
}

// MARK: - DynamicList Wrapper

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
private struct DynamicListWrapper<Item: Identifiable & Hashable>: View {
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: (Item) -> AnyView
    private let errorContent: ((Error) -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool

    init(
        viewModel: DynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: @escaping (Item) -> AnyView,
        errorContent: ((Error) -> AnyView)?,
        title: String?,
        navigationBarHidden: Bool,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.title = title
        self.navigationBarHidden = navigationBarHidden
    }

    var body: some View {
        NavigationStack {
            DynamicListContent(
                viewModel: viewModel,
                rowContent: rowContent,
                detailContent: detailContent,
                errorContent: errorContent,
                title: title,
                navigationBarHidden: navigationBarHidden,
            )
        }
    }
}

// MARK: - DynamicList Content

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
private struct DynamicListContent<Item: Identifiable & Hashable>: View {
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> AnyView
    private let detailContent: (Item) -> AnyView
    private let errorContent: ((Error) -> AnyView)?
    private let title: String?
    private let navigationBarHidden: Bool

    init(
        viewModel: DynamicListViewModel<Item>,
        rowContent: @escaping (Item) -> AnyView,
        detailContent: @escaping (Item) -> AnyView,
        errorContent: ((Error) -> AnyView)?,
        title: String?,
        navigationBarHidden: Bool,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
        self.title = title
        self.navigationBarHidden = navigationBarHidden
    }

    var body: some View {
        Group {
            if viewModel.viewState.shouldShowLoading {
                ProgressView(DynamicListPresenter.loadingContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.viewState.shouldShowError {
                errorView
            } else {
                List(viewModel.viewState.items) { item in
                    NavigationLink(value: item) {
                        rowContent(item)
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
        .navigationTitle(title ?? "")
        #if os(iOS)
            .navigationBarHidden(navigationBarHidden)
        #endif
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

// MARK: - Default Views

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
private struct DefaultRowView<Item: Identifiable & Hashable>: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(item)")
                .font(.body)
            Text("ID: \(item.id)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
private struct DefaultDetailView<Item: Identifiable & Hashable>: View {
    let item: Item

    var body: some View {
        VStack(spacing: 16) {
            Text(DynamicListPresenter.itemDetail)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(item)")
                .font(.body)

            Text("\(DynamicListPresenter.itemID): \(item.id)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Convenience Factory Methods

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension DynamicListBuilder {
    /// Creates a simple list with static items
    @MainActor
    static func simple(
        items: [Item],
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .items(items)
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }

    /// Creates a list with a publisher data source
    @MainActor
    static func reactive(
        publisher: AnyPublisher<[Item], Error>,
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .publisher(publisher)
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }

    /// Creates a list with simulated loading
    @MainActor
    static func simulated(
        items: [Item],
        delay: TimeInterval = 1.0,
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .simulatedPublisher(items, delay: delay)
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }
}
