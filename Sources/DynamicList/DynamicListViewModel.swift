//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import Observation

/// An observable view model to hold and manage a collection of items for a `DynamicList`.
///
/// This view model uses the Observation framework to allow SwiftUI views to automatically
/// track changes to the `items` array. It also supports reactive data loading using Combine publishers.
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
@Observable
public final class DynamicListViewModel<Item: Identifiable & Hashable> {
    /// The collection of items to be displayed.
    public var items: [Item]

    /// Indicates whether data is currently being loaded.
    public var isLoading: Bool = false

    /// Contains any error that occurred during data loading.
    public var error: Error?

    /// Set to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the view model with an initial set of items.
    /// - Parameter items: The initial array of items. Defaults to an empty array.
    public init(items: [Item] = []) {
        self.items = items
    }

    /// Initializes the view model with a publisher that emits arrays of items.
    ///
    /// This initializer allows you to connect the view model to external data sources
    /// like Firebase, local JSON files, or any other service that returns a Combine publisher.
    ///
    /// - Parameters:
    ///   - publisher: A Combine publisher that emits arrays of items.
    ///   - initialItems: Initial items to display while loading. Defaults to an empty array.
    public init(publisher: AnyPublisher<[Item], Error>, initialItems: [Item] = []) {
        items = initialItems
        isLoading = true

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        self?.error = nil
                    case let .failure(error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] items in
                    self?.items = items
                    self?.error = nil
                },
            )
            .store(in: &cancellables)
    }

    /// Updates the items by subscribing to a new publisher.
    ///
    /// This method allows you to change the data source dynamically or refresh the data.
    ///
    /// - Parameter publisher: A new publisher that emits arrays of items.
    public func loadItems(from publisher: AnyPublisher<[Item], Error>) {
        // Cancel previous subscriptions
        cancellables.removeAll()

        isLoading = true
        error = nil

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        self?.error = nil
                    case let .failure(error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] items in
                    self?.items = items
                    self?.error = nil
                },
            )
            .store(in: &cancellables)
    }

    /// Reloads the data by resubscribing to the current publisher if available.
    public func refresh() {
        // This would be implemented if we stored the original publisher
        // For now, this method exists for future extensibility
    }
}
