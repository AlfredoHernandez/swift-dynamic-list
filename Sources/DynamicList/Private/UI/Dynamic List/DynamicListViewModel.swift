//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation
import Observation

@Observable
final class DynamicListViewModel<Item: Identifiable & Hashable>: DynamicListViewModelProtocol {
    var viewState: DynamicListViewState<Item>
    var scheduler: AnySchedulerOf<DispatchQueue>
    var ioScheduler: AnySchedulerOf<DispatchQueue>

    private var cancellables = Set<AnyCancellable>()
    private var dataProvider: (() -> AnyPublisher<[Item], Error>)?
    private var searchConfiguration: SearchConfiguration<Item>?
    private let searchTextSubject = CurrentValueSubject<String, Error>("")
    private var originalItems: [Item] = []

    var searchText: String {
        get { searchTextSubject.value }
        set { searchTextSubject.send(newValue) }
    }

    init(
        items: [Item] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        ioScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
    ) {
        viewState = .idle(items: items)
        self.scheduler = scheduler
        self.ioScheduler = ioScheduler
        originalItems = items
        setupSearchTextObserverForStaticData()
    }

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
        setupSearchTextObserverForStaticData()
    }

    func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>) {
        self.dataProvider = dataProvider
        loadData()
    }

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

    func refresh() {
        loadData()
    }

    func search(query: String) {
        searchText = query
        if dataProvider == nil {
            applySearchFilterToCurrentItems()
        }
    }

    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        searchConfiguration = configuration
    }

    private func setupSearchTextObserverForStaticData() {
        searchTextSubject
            .dropFirst()
            .subscribe(on: ioScheduler)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    if self?.dataProvider == nil {
                        self?.applySearchFilterToCurrentItems()
                    }
                },
            )
            .store(in: &cancellables)
    }

    private func applySearchFilterToCurrentItems() {
        let filteredItems = applySearchFilter(to: originalItems, searchText: searchText)
        viewState = .loaded(items: filteredItems)
    }

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

extension DynamicListViewModel {
    var items: [Item] { viewState.items }
    var isLoading: Bool { viewState.isLoading }
    var error: Error? { viewState.error }
}
