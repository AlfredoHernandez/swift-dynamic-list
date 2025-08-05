//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents the complete view state for a dynamic list
struct DynamicListViewState<Item: Identifiable & Hashable>: Equatable {
    /// The current loading state
    let loadingState: LoadingState

    /// The items to display in the list
    let items: [Item]

    /// Creates a new view state
    /// - Parameters:
    ///   - loadingState: The current loading state
    ///   - items: The items to display
    init(loadingState: LoadingState, items: [Item]) {
        self.loadingState = loadingState
        self.items = items
    }

    /// Creates an idle state with the given items
    static func idle(items: [Item] = []) -> Self {
        Self(loadingState: .idle, items: items)
    }

    /// Creates a loading state with the given items (useful for showing previous data while loading new data)
    static func loading(items: [Item] = []) -> Self {
        Self(loadingState: .loading, items: items)
    }

    /// Creates a loaded state with the given items
    static func loaded(items: [Item]) -> Self {
        Self(loadingState: .loaded, items: items)
    }

    /// Creates an error state with the given error and items
    static func error(_ error: Error, items: [Item] = []) -> Self {
        Self(loadingState: .error(error), items: items)
    }
}

// MARK: - Convenience Properties

extension DynamicListViewState {
    /// Returns true if the state is loading
    var isLoading: Bool { loadingState.isLoading }

    /// Returns the error if there is one
    var error: Error? { loadingState.error }

    /// Returns true if there is an error
    var hasError: Bool { loadingState.hasError }

    /// Returns true if data has been loaded successfully
    var isLoaded: Bool { loadingState.isLoaded }

    /// Returns true if the list is empty
    var isEmpty: Bool { items.isEmpty }

    /// Returns true if should show loading indicator (loading and no items)
    var shouldShowLoading: Bool { isLoading && isEmpty }

    /// Returns true if should show error state (has error and no items)
    var shouldShowError: Bool { hasError && isEmpty }

    /// Returns true if should show the list
    var shouldShowList: Bool { !isEmpty }
}
