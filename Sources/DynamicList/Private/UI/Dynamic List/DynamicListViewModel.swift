//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation
import Observation

/// An observable view model to hold and manage a collection of items for a `DynamicList`.
///
/// This view model uses the Observation framework to allow SwiftUI views to automatically
/// track changes to the view state. It also supports reactive data loading using Combine publishers.
@Observable
final class DynamicListViewModel<Item: Identifiable & Hashable> {
    /// The current view state containing items and loading information.
    var viewState: DynamicListViewState<Item>

    var scheduler: AnySchedulerOf<DispatchQueue>

    /// Set to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Closure that provides a publisher for loading data.
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?

    /// Search configuration for filtering items
    private var searchConfiguration: SearchConfiguration<Item>?

    /// Current search text
    private var searchText: String = ""

    /// Initializes the view model with an initial set of items.
    /// - Parameter items: The initial array of items. Defaults to an empty array.
    init(items: [Item] = [], scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        viewState = .idle(items: items)
        self.scheduler = scheduler
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
    init(dataProvider: @escaping () -> AnyPublisher<[Item], Error>, initialItems: [Item] = [], scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.dataProvider = dataProvider
        viewState = .loading(items: initialItems)
        self.scheduler = scheduler
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
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
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

    /// Sets the search configuration for filtering items.
    ///
    /// - Parameter configuration: The search configuration to use for filtering.
    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    /// Updates the search text and triggers filtering.
    ///
    /// - Parameter text: The new search text to filter by.
    func updateSearchText(_ text: String) {
        searchText = text
    }

    /// Returns the filtered items based on the current search text and configuration.
    ///
    /// If no search text is provided or no search configuration is set,
    /// returns all items. Otherwise, applies the search logic to filter items.
    ///
    /// - Returns: The filtered array of items.
    func filteredItems() -> [Item] {
        guard !searchText.isEmpty else {
            return viewState.items
        }

        return viewState.items.filter { item in
            if let searchConfiguration {
                if let predicate = searchConfiguration.predicate {
                    return predicate(item, searchText)
                } else if let searchableItem = item as? Searchable {
                    let strategy = searchConfiguration.strategy ?? PartialMatchStrategy()
                    return strategy.matches(query: searchText, in: searchableItem)
                }
            }

            // Fallback: try to use description if available
            return String(describing: item).lowercased().contains(searchText.lowercased())
        }
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

    /// The filtered collection of items based on current search text and configuration.
    var filteredItemsList: [Item] {
        filteredItems()
    }
}
