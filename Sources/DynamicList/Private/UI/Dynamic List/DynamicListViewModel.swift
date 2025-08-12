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
final class DynamicListViewModel<Item: Identifiable & Hashable>: DynamicListViewModelProtocol {
    /// The current view state containing items and loading information.
    var viewState: DynamicListViewState<Item>

    /// Scheduler for UI updates
    var scheduler: AnySchedulerOf<DispatchQueue>

    /// Scheduler for background operations like filtering
    var ioScheduler: AnySchedulerOf<DispatchQueue>

    /// Set to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Closure that provides a publisher for loading data.
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?

    /// Search configuration for filtering items
    private var searchConfiguration: SearchConfiguration<Item>?

    /// Publisher for search text changes
    private let searchTextSubject = CurrentValueSubject<String, Error>("")

    /// Current search text
    var searchText: String {
        get { searchTextSubject.value }
        set { searchTextSubject.send(newValue) }
    }

    /// Original items for filtering (used for static data)
    private var originalItems: [Item] = []

    /// Initializes the view model with an initial set of items.
    /// - Parameters:
    ///   - items: The initial array of items. Defaults to an empty array.
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    init(
        items: [Item] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(items: items)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        originalItems = items

        // Set up search text observer for static data
        setupSearchTextObserver()
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
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    init(
        dataProvider: @escaping () -> AnyPublisher<[Item], Error>,
        initialItems: [Item] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        self.dataProvider = dataProvider
        viewState = .loading(items: initialItems)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler

        // Set up search text observer for reactive data
        setupSearchTextObserver()
    }

    /// Updates the items by subscribing to a new data provider.
    ///
    /// This method allows you to change the data source dynamically or refresh the data.
    ///
    /// - Parameter dataProvider: A new closure that returns a publisher emitting arrays of items.
    func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>) {
        self.dataProvider = dataProvider
        setupSearchTextObserver()
        loadData()
    }

    /// Loads data using the current data provider.
    ///
    /// This method is called internally to load data and can be used to refresh the current data.
    func loadData() {
        guard let provider = dataProvider else { return }

        cancelPreviousSubscriptions()
        preserveCurrentItemsWhileLoading()

        provider()
            .flatMap { [weak self] items -> AnyPublisher<[Item], Error> in
                guard let self else { return Just(items).setFailureType(to: Error.self).eraseToAnyPublisher() }

                return searchTextSubject
                    .map { searchText in
                        self.originalItems = items
                        return self.applySearchFilter(to: items, searchText: searchText)
                    }
                    .eraseToAnyPublisher()
            }
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleDataLoadCompletion(completion)
                },
                receiveValue: { [weak self] filteredItems in
                    self?.viewState = .loaded(items: filteredItems)
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

    func search(query: String) {
        searchText = query
        // For static data (no dataProvider), apply filtering immediately and synchronously
        if dataProvider == nil {
            applySearchFilterToCurrentItems()
        }
    }

    /// Sets the search configuration for filtering items.
    ///
    /// - Parameter configuration: The search configuration to use for filtering.
    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    /// Sets up the search text observer to handle filtering for static data.
    private func setupSearchTextObserver() {
        searchTextSubject
            .dropFirst() // Skip initial empty value
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    // Only apply filtering for static data (no dataProvider)
                    if self?.dataProvider == nil {
                        self?.applySearchFilterToCurrentItems()
                    }
                },
            )
            .store(in: &cancellables)
    }

    /// Applies search filter to current items when search text changes.
    /// This method is used for static data scenarios.
    private func applySearchFilterToCurrentItems() {
        let currentItems = originalItems
        let filteredItems = applySearchFilter(to: currentItems, searchText: searchText)
        viewState = .loaded(items: filteredItems)
    }

    // MARK: - Private Helper Methods

    private func cancelPreviousSubscriptions() {
        cancellables.removeAll()
    }

    private func preserveCurrentItemsWhileLoading() {
        viewState = .loading(items: viewState.items)
    }

    private func handleDataLoadCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished: break
        case let .failure(error):
            viewState = .error(error, items: viewState.items)
        }
    }

    /// Applies search filter to the given items.
    ///
    /// - Parameters:
    ///   - items: The items to filter.
    ///   - searchText: The search text to filter by.
    /// - Returns: The filtered array of items.
    private func applySearchFilter(to items: [Item], searchText: String) -> [Item] {
        guard !searchText.isEmpty else {
            return items
        }

        return items.filter { item in
            if let searchConfiguration {
                if let predicate = searchConfiguration.predicate {
                    let result = predicate(item, searchText)
                    return result
                } else if let searchableItem = item as? Searchable {
                    let strategy = searchConfiguration.strategy ?? PartialMatchStrategy()
                    let result = strategy.matches(query: searchText, in: searchableItem)

                    return result
                }
            }

            // Fallback: try to use description if available
            let result = String(describing: item).lowercased().contains(searchText.lowercased())
            return result
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
}
