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
    var viewState: ListViewState<Item>

    var scheduler: AnySchedulerOf<DispatchQueue>

    /// Set to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Closure that provides a publisher for loading data.
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?

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

//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

/// A view model that manages the state of a dynamic list with sections.
///
/// This view model handles loading states, error handling, and data management for lists
/// that display data in sections. It supports both static data and reactive publishers.
@Observable
public final class SectionedDynamicListViewModel<Item: Identifiable & Hashable> {
    // MARK: - Private Properties

    /// The current view state
    private(set) var viewState: SectionedListViewState<Item>

    /// The data provider closure that returns a publisher
    private var dataProvider: (() -> AnyPublisher<[[Item]], Error>)?

    /// The current subscription to the data provider
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new view model with static sections.
    ///
    /// - Parameter sections: The sections to display in the list.
    public init(sections: [ListSection<Item>] = []) {
        viewState = .idle(sections: sections)
    }

    /// Creates a new view model with static arrays of items.
    ///
    /// - Parameters:
    ///   - arrays: Array of arrays representing sections
    ///   - titles: Optional titles for each section
    public convenience init(arrays: [[Item]], titles: [String?] = []) {
        let sections = zip(arrays, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        self.init(sections: sections)
    }

    /// Creates a new view model with a data provider.
    ///
    /// - Parameters:
    ///   - dataProvider: A closure that returns a publisher emitting arrays of arrays
    ///   - initialSections: Initial sections to display while loading
    ///   - scheduler: The scheduler to use for receiving data (defaults to main queue)
    public init(
        dataProvider: @escaping () -> AnyPublisher<[[Item]], Error>,
        initialSections: [ListSection<Item>] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
    ) {
        viewState = .idle(sections: initialSections)
        self.dataProvider = dataProvider
        loadData(scheduler: scheduler)
    }

    // MARK: - Public Methods

    /// Loads data from the current data provider.
    ///
    /// This method will update the view state to loading and then subscribe to the
    /// data provider to receive updates.
    ///
    /// - Parameter scheduler: The scheduler to use for receiving data
    public func loadData(scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        guard let dataProvider else { return }

        viewState = .loading(sections: viewState.sections)

        dataProvider()
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.viewState = .error(error, sections: self?.viewState.sections ?? [])
                    }
                },
                receiveValue: { [weak self] arrays in
                    let sections = arrays.map { ListSection(title: nil, items: $0) }
                    self?.viewState = .loaded(sections: sections)
                },
            )
            .store(in: &cancellables)
    }

    /// Loads data from a new data provider.
    ///
    /// This method will replace the current data provider and immediately start loading
    /// data from the new provider.
    ///
    /// - Parameters:
    ///   - dataProvider: A closure that returns a publisher emitting arrays of arrays
    ///   - scheduler: The scheduler to use for receiving data
    public func loadItems(
        from dataProvider: @escaping () -> AnyPublisher<[[Item]], Error>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
    ) {
        self.dataProvider = dataProvider
        loadData(scheduler: scheduler)
    }

    /// Refreshes the data by calling the current data provider again.
    ///
    /// This method will trigger a new subscription to the data provider, effectively
    /// reloading the data.
    public func refresh() {
        loadData()
    }

    /// Updates the sections with new data.
    ///
    /// - Parameter sections: The new sections to display
    public func updateSections(_ sections: [ListSection<Item>]) {
        viewState = .loaded(sections: sections)
    }

    /// Updates the sections with arrays of items.
    ///
    /// - Parameters:
    ///   - arrays: Array of arrays representing sections
    ///   - titles: Optional titles for each section
    public func updateSections(arrays: [[Item]], titles: [String?] = []) {
        let sections = zip(arrays, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        updateSections(sections)
    }
}
