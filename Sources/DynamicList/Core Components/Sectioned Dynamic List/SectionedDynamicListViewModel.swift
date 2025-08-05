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
