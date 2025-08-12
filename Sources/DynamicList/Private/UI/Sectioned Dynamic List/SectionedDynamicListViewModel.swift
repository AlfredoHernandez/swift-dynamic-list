//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation

/// A view model that manages the state of a dynamic list with sections.
///
/// This view model handles loading states, error handling, and data management for lists
/// that display data in sections. It supports both static data and reactive publishers.
@Observable
final class SectionedDynamicListViewModel<Item: Identifiable & Hashable>: DynamicListViewModelProtocol {
    // MARK: - Private Properties

    /// The current view state
    private(set) var viewState: SectionedListViewState<Item>

    /// Scheduler for UI updates
    private var scheduler: AnySchedulerOf<DispatchQueue>

    /// Scheduler for background operations like filtering
    private var ioScheduler: AnySchedulerOf<DispatchQueue>

    /// The data provider closure that returns a publisher
    private var dataProvider: (() -> AnyPublisher<[[Item]], Error>)?

    /// The current subscription to the data provider
    private var cancellables = Set<AnyCancellable>()

    /// Search configuration for filtering items
    private(set) var searchConfiguration: SearchConfiguration<Item>?

    /// Search text subject for reactive filtering
    private let searchTextSubject = CurrentValueSubject<String, Error>("")

    /// Current search text
    var searchText: String {
        get { searchTextSubject.value }
        set { searchTextSubject.send(newValue) }
    }

    /// Current unfiltered sections (for filtering operations)
    private var originalSections: [ListSection<Item>] = []

    // MARK: - Initialization

    /// Creates a new view model with static sections.
    ///
    /// - Parameters:
    ///   - sections: The sections to display in the list.
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    init(
        sections: [ListSection<Item>] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(sections: sections)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        originalSections = sections
        setupSearchTextObserverForStaticData()
    }

    /// Creates a new view model with static arrays of items.
    ///
    /// - Parameters:
    ///   - arrays: Array of arrays representing sections
    ///   - titles: Optional titles for each section
    convenience init(arrays: [[Item]], titles: [String?] = []) {
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
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    init(
        dataProvider: @escaping () -> AnyPublisher<[[Item]], Error>,
        initialSections: [ListSection<Item>] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(sections: initialSections)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        originalSections = initialSections
        self.dataProvider = dataProvider
        setupSearchTextObserverForStaticData()
    }

    // MARK: -  Methods

    /// Loads data from the current data provider.
    ///
    /// This method will update the view state to loading and then subscribe to the
    /// data provider to receive updates.
    func loadData() {
        guard let provider = dataProvider else { return }

        cancelPreviousSubscriptions()
        preserveCurrentSectionsWhileLoading()

        provider()
            .flatMap { [weak self] arrays -> AnyPublisher<[ListSection<Item>], Error> in
                guard let self else {
                    let sections = arrays.map { ListSection(title: nil, items: $0) }
                    return Just(sections).setFailureType(to: Error.self).eraseToAnyPublisher()
                }

                return createFilteredSectionsPublisher(from: arrays)
            }
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleDataLoadCompletion(completion)
                },
                receiveValue: { [weak self] filteredSections in
                    self?.updateViewStateWithLoadedSections(filteredSections)
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
    func loadItems(from dataProvider: @escaping () -> AnyPublisher<[[Item]], Error>) {
        self.dataProvider = dataProvider
        loadData()
    }

    /// Refreshes the data by calling the current data provider again.
    ///
    /// This method will trigger a new subscription to the data provider, effectively
    /// reloading the data.
    func refresh() {
        loadData()
    }

    func search(query: String) {
        updateSearchText(query)
    }

    private func updateSearchText(_ query: String) {
        searchText = query
    }

    /// Updates the sections with new data.
    ///
    /// - Parameter sections: The new sections to display
    func updateSections(_ sections: [ListSection<Item>]) {
        originalSections = sections
        viewState = .loaded(sections: sections)
    }

    /// Updates the sections with arrays of items.
    ///
    /// - Parameters:
    ///   - arrays: Array of arrays representing sections
    ///   - titles: Optional titles for each section
    func updateSections(arrays: [[Item]], titles: [String?] = []) {
        let sections = zip(arrays, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        updateSections(sections)
    }

    // MARK: - Search Methods

    /// Sets the search configuration for filtering items.
    ///
    /// - Parameter configuration: The search configuration to use for filtering.
    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    // MARK: - Private Helper Methods

    private func setupSearchTextObserverForStaticData() {
        searchTextSubject
            .dropFirst()
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    if self?.dataProvider == nil {
                        self?.applySearchFilterToCurrentSections()
                    }
                },
            )
            .store(in: &cancellables)
    }

    private func applySearchFilterToCurrentSections() {
        let filteredSections = applySearchFilter(to: originalSections, searchText: searchText)
        viewState = .loaded(sections: filteredSections)
    }

    private func cancelPreviousSubscriptions() {
        cancellables.removeAll()
    }

    private func preserveCurrentSectionsWhileLoading() {
        viewState = .loading(sections: viewState.sections)
    }

    private func handleDataLoadCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished: break
        case let .failure(error):
            viewState = .error(error, sections: viewState.sections)
        }
    }

    /// Applies search filter to the given sections.
    ///
    /// - Parameters:
    ///   - sections: The sections to filter.
    ///   - searchText: The search text to filter by.
    /// - Returns: The filtered array of sections.
    private func applySearchFilter(to sections: [ListSection<Item>], searchText: String) -> [ListSection<Item>] {
        guard !searchText.isEmpty else {
            return sections
        }

        return sections.compactMap { section in
            let filteredItems = section.items.filter { item in
                matchesSearchConfiguration(for: item, searchText: searchText)
            }
            return createSectionWithMatchingItems(from: section, filteredItems: filteredItems)
        }
    }

    private func matchesSearchConfiguration(for item: Item, searchText: String) -> Bool {
        if let searchConfiguration {
            if let predicate = searchConfiguration.predicate {
                return predicate(item, searchText)
            } else if let searchableItem = item as? Searchable {
                let strategy = searchConfiguration.strategy ?? PartialMatchStrategy()
                return strategy.matches(query: searchText, in: searchableItem)
            }
        }

        return matchesItemDescription(item: item, searchText: searchText)
    }

    private func matchesItemDescription(item: Item, searchText: String) -> Bool {
        String(describing: item).lowercased().contains(searchText.lowercased())
    }

    private func createSectionWithMatchingItems(from section: ListSection<Item>, filteredItems: [Item]) -> ListSection<Item>? {
        guard !filteredItems.isEmpty else { return nil }

        return ListSection(
            title: section.title,
            items: filteredItems,
            footer: section.footer,
        )
    }

    private func createFilteredSectionsPublisher(from arrays: [[Item]]) -> AnyPublisher<[ListSection<Item>], Error> {
        searchTextSubject
            .map { searchText in
                let sections = arrays.map { ListSection(title: nil, items: $0) }
                self.originalSections = sections
                return self.applySearchFilter(to: sections, searchText: searchText)
            }
            .eraseToAnyPublisher()
    }

    private func updateViewStateWithLoadedSections(_ sections: [ListSection<Item>]) {
        viewState = .loaded(sections: sections)
    }

    // MARK: - Convenience Properties

    /// The collection of sections to be displayed.
    var sections: [ListSection<Item>] {
        viewState.sections
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
