//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import Observation

/// An observable view model to hold and manage a collection of items for a `DynamicList`.
///
/// This view model uses the Observation framework to allow SwiftUI views to automatically
/// track changes to the view state. It also supports reactive data loading using Combine publishers.
@Observable
final class DynamicListViewModel<Item: Identifiable & Hashable> {
    /// The current view state containing items and loading information.
    var viewState: ListViewState<Item>

    /// Set to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Closure that provides a publisher for loading data.
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?

    /// Initializes the view model with an initial set of items.
    /// - Parameter items: The initial array of items. Defaults to an empty array.
    init(items: [Item] = []) {
        viewState = .idle(items: items)
    }

    /// Initializes the view model with a data provider closure that returns a publisher.
    ///
    /// This initializer allows you to connect the view model to external data sources
    /// like Firebase, local JSON files, or any other service that returns a Combine publisher.
    /// The closure is called each time data needs to be loaded, ensuring fresh data on refresh.
    ///
    /// - Parameters:
    ///   - dataProvider: A closure that returns a Combine publisher emitting arrays of items.
    ///   - initialItems: Initial items to display while loading. Defaults to an empty array.
    init(dataProvider: @escaping () -> AnyPublisher<[Item], Error>, initialItems: [Item] = []) {
        self.dataProvider = dataProvider
        viewState = .loading(items: initialItems)
        loadData()
    }

    /// Updates the items by subscribing to a new data provider.
    ///
    /// This method allows you to change the data source dynamically or refresh the data.
    ///
    /// - Parameter dataProvider: A new closure that returns a publisher emitting arrays of items.
    func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>) {
        self.dataProvider = dataProvider
        loadData()
    }

    /// Loads data using the current data provider.
    ///
    /// This method is called internally to load data and can be used to refresh the current data.
    private func loadData() {
        guard let provider = dataProvider else { return }

        // Cancel previous subscriptions
        cancellables.removeAll()

        // Preserve current items while loading new ones
        viewState = .loading(items: viewState.items)

        provider()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        // State is already updated in receiveValue
                        break
                    case let .failure(error):
                        self?.viewState = .error(error, items: self?.viewState.items ?? [])
                    }
                },
                receiveValue: { [weak self] items in
                    self?.viewState = .loaded(items: items)
                },
            )
            .store(in: &cancellables)
    }

    /// Reloads the data by calling the current data provider.
    ///
    /// This method triggers a fresh data load using the current data provider,
    /// ensuring that the latest data is retrieved.
    func refresh() {
        loadData()
    }
}

// MARK: - Convenience Properties (for backward compatibility)

extension DynamicListViewModel {
    /// The collection of items to be displayed.
    var items: [Item] {
        viewState.items
    }

    /// Indicates whether data is currently being loaded.
    var isLoading: Bool {
        viewState.isLoading
    }

    /// Contains any error that occurred during data loading.
    var error: Error? {
        viewState.error
    }
}
