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
public final class SectionedDynamicListViewModel<Item: Identifiable & Hashable> {
    // MARK: - Private Properties

    /// The current view state
    private(set) var viewState: SectionedListViewState<Item>

    /// Scheduler for UI updates
    var scheduler: AnySchedulerOf<DispatchQueue>

    /// Scheduler for background operations like filtering
    var ioScheduler: AnySchedulerOf<DispatchQueue>

    /// The data provider closure that returns a publisher
    private var dataProvider: (() -> AnyPublisher<[[Item]], Error>)?

    /// The current subscription to the data provider
    private var cancellables = Set<AnyCancellable>()

    /// Search configuration for filtering items
    private var searchConfiguration: SearchConfiguration<Item>?

    /// Current search text
    var searchText: String = ""

    /// Current unfiltered sections (for filtering operations)
    private var allSections: [ListSection<Item>] = []

    // MARK: - Initialization

    /// Creates a new view model with static sections.
    ///
    /// - Parameters:
    ///   - sections: The sections to display in the list.
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    public init(
        sections: [ListSection<Item>] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(sections: sections)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        allSections = sections
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
    ///   - scheduler: The scheduler for UI updates. Defaults to main queue.
    ///   - ioScheduler: The scheduler for background operations. Defaults to background queue.
    public init(
        dataProvider: @escaping () -> AnyPublisher<[[Item]], Error>,
        initialSections: [ListSection<Item>] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(sections: initialSections)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        allSections = initialSections
        self.dataProvider = dataProvider
        loadData()
    }

    // MARK: - Public Methods

    /// Loads data from the current data provider.
    ///
    /// This method will update the view state to loading and then subscribe to the
    /// data provider to receive updates.
    public func loadData() {
        guard let dataProvider else { return }

        viewState = .loading(sections: viewState.sections)

        dataProvider()
            .subscribe(on: ioScheduler)
            .map { [weak self] arrays -> [ListSection<Item>] in
                let sections = arrays.map { ListSection(title: nil, items: $0) }

                // Store unfiltered sections for future filtering
                self?.allSections = sections

                // Apply current search filter if any
                return self?.applySearchFilter(to: sections) ?? sections
            }
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
                receiveValue: { [weak self] filteredSections in
                    self?.viewState = .loaded(sections: filteredSections)
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
        scheduler _: AnySchedulerOf<DispatchQueue> = .main,
    ) {
        self.dataProvider = dataProvider
        loadData()
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

    // MARK: - Search Methods

    /// Sets the search configuration for filtering items.
    ///
    /// - Parameter configuration: The search configuration to use for filtering.
    public func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    /// Updates the search text and triggers filtering.
    ///
    /// - Parameter text: The new search text to filter by.
    public func updateSearchText(_ text: String) {
        searchText = text

        // Apply filter to current sections on background thread
        ioScheduler.schedule {
            let filteredSections = self.applySearchFilter(to: self.allSections)

            self.scheduler.schedule {
                self.viewState = .loaded(sections: filteredSections)
            }
        }
    }

    /// Applies search filter to the given sections.
    ///
    /// - Parameter sections: The sections to filter.
    /// - Returns: The filtered array of sections.
    private func applySearchFilter(to sections: [ListSection<Item>]) -> [ListSection<Item>] {
        guard !searchText.isEmpty else {
            return sections
        }

        return sections.compactMap { section in
            let filteredItems = section.items.filter { item in
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

            // Only include sections that have matching items
            guard !filteredItems.isEmpty else { return nil }

            return ListSection(
                title: section.title,
                items: filteredItems,
                footer: section.footer,
            )
        }
    }

    /// Returns the filtered sections based on the current search text and configuration.
    ///
    /// If no search text is provided or no search configuration is set,
    /// returns all sections. Otherwise, applies the search logic to filter sections.
    ///
    /// - Returns: The filtered array of sections.
    public func filteredSections() -> [ListSection<Item>] {
        viewState.sections
    }

    // MARK: - Convenience Properties

    /// The filtered sections based on current search text and configuration.
    public var filteredSectionsList: [ListSection<Item>] {
        filteredSections()
    }
}
