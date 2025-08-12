//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation
import Observation

/// A view model that manages the state of a dynamic list.
///
/// This view model handles loading states, error handling, and data management for lists
/// that display data in a flat structure. It supports both static data and reactive publishers.
@Observable
final class DynamicListViewModel<Item: Identifiable & Hashable>: DynamicListViewModelProtocol {
    var viewState: DynamicListViewState<Item>
    private var scheduler: AnySchedulerOf<DispatchQueue>
    private var ioScheduler: AnySchedulerOf<DispatchQueue>

    private var cancellables = Set<AnyCancellable>()
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?
    private var searchConfiguration: SearchConfiguration<Item>?
    private let searchTextSubject = CurrentValueSubject<String, Error>("")
    private var originalItems: [Item] = []

    var searchText: String {
        get { searchTextSubject.value }
        set { searchTextSubject.send(newValue) }
    }

    // MARK: - Initialization

    /// Creates a new view model with static items.
    ///
    /// - Parameters:
    ///   - items: The items to display in the list.
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
        setupSearchTextObserverForStaticDataMode()
    }

    /// Creates a new view model with a data provider.
    ///
    /// - Parameters:
    ///   - dataProvider: A closure that returns a publisher emitting items
    ///   - initialItems: Initial items to display while loading
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
        setupSearchTextObserverForStaticDataMode()
    }

    // MARK: - Public Methods

    /// Loads data from a new data provider.
    ///
    /// This method will replace the current data provider and immediately start loading
    /// data from the new provider.
    ///
    /// - Parameters:
    ///   - dataProvider: A closure that returns a publisher emitting items
    func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>) {
        self.dataProvider = dataProvider
        loadData()
    }

    /// Loads data from the current data provider.
    ///
    /// This method will update the view state to loading and then subscribe to the
    /// data provider to receive updates.
    func loadData() {
        guard let provider = dataProvider else { return }

        prepareForDataLoading()
        subscribeToDataProvider(provider)
    }

    func refresh() {
        loadData()
    }

    func search(query: String) {
        updateSearchText(query)
        if dataProvider == nil {
            filterCurrentItemsWithSearchText()
        }
    }

    private func updateSearchText(_ query: String) {
        searchText = query
    }

    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    // MARK: - Private Helper Methods

    private func prepareForDataLoading() {
        clearAllSubscriptions()
        setLoadingStateWithCurrentItems()
    }

    private func subscribeToDataProvider(_ provider: () -> AnyPublisher<[Item], Error>) {
        provider()
            .flatMap { [weak self] items -> AnyPublisher<[Item], Error> in
                guard let self else { return Just(items).setFailureType(to: Error.self).eraseToAnyPublisher() }

                return createFilteredItemsPublisher(from: items)
            }
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleDataLoadCompletion(completion)
                },
                receiveValue: { [weak self] filteredItems in
                    self?.updateViewStateWithLoadedItems(filteredItems)
                },
            )
            .store(in: &cancellables)
    }

    private func createFilteredItemsPublisher(from items: [Item]) -> AnyPublisher<[Item], Error> {
        searchTextSubject
            .map { searchText in
                self.originalItems = items
                return self.applySearchFilter(to: items, searchText: searchText)
            }
            .eraseToAnyPublisher()
    }

    private func updateViewStateWithLoadedItems(_ items: [Item]) {
        viewState = .loaded(items: items)
    }

    private func setupSearchTextObserverForStaticDataMode() {
        searchTextSubject
            .dropFirst()
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    if self?.dataProvider == nil {
                        self?.filterCurrentItemsWithSearchText()
                    }
                },
            )
            .store(in: &cancellables)
    }

    private func filterCurrentItemsWithSearchText() {
        let filteredItems = applySearchFilter(to: originalItems, searchText: searchText)
        viewState = .loaded(items: filteredItems)
    }

    private func clearAllSubscriptions() {
        cancellables.removeAll()
    }

    private func setLoadingStateWithCurrentItems() {
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
        guard !searchText.isEmpty else { return items }

        return items.filter { item in
            if let searchConfiguration {
                if let predicate = searchConfiguration.predicate {
                    return predicate(item, searchText)
                } else if let searchableItem = item as? Searchable {
                    let strategy = searchConfiguration.strategy ?? PartialMatchStrategy()
                    return strategy.matches(query: searchText, in: searchableItem)
                }
            }

            return String(describing: item).lowercased().contains(searchText.lowercased())
        }
    }
}

// MARK: - Convenience Properties

extension DynamicListViewModel {
    var items: [Item] { viewState.items }
    var isLoading: Bool { viewState.isLoading }
    var error: Error? { viewState.error }
}
