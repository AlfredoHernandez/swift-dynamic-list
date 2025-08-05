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

    /// Initializes the view model with an initial set of items.
    /// - Parameter items: The initial array of items. Defaults to an empty array.
    init(items: [Item] = []) {
        viewState = .idle(items: items)
    }

    /// Initializes the view model with a publisher that emits arrays of items.
    ///
    /// This initializer allows you to connect the view model to external data sources
    /// like Firebase, local JSON files, or any other service that returns a Combine publisher.
    ///
    /// - Parameters:
    ///   - publisher: A Combine publisher that emits arrays of items.
    ///   - initialItems: Initial items to display while loading. Defaults to an empty array.
    init(publisher: AnyPublisher<[Item], Error>, initialItems: [Item] = []) {
        viewState = .loading(items: initialItems)

        publisher
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

    /// Updates the items by subscribing to a new publisher.
    ///
    /// This method allows you to change the data source dynamically or refresh the data.
    ///
    /// - Parameter publisher: A new publisher that emits arrays of items.
    func loadItems(from publisher: AnyPublisher<[Item], Error>) {
        // Cancel previous subscriptions
        cancellables.removeAll()

        // Preserve current items while loading new ones
        viewState = .loading(items: viewState.items)

        publisher
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

    /// Reloads the data by resubscribing to the current publisher if available.
    func refresh() {
        // This would be implemented if we stored the original publisher
        // For now, this method exists for future extensibility
        // We could set the state to loading to show refresh indicator
        if !viewState.items.isEmpty {
            viewState = .loading(items: viewState.items)
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
