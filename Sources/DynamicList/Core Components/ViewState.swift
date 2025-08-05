//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents the different loading states of the list
public enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(Error)

    public static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
            true
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }

    /// Returns true if the state is loading
    public var isLoading: Bool {
        if case .loading = self { true } else { false }
    }

    /// Returns the error if the state is error, nil otherwise
    public var error: Error? {
        if case let .error(error) = self { error } else { nil }
    }

    /// Returns true if the state has an error
    public var hasError: Bool {
        if case .error = self { true } else { false }
    }

    /// Returns true if data has been loaded successfully
    public var isLoaded: Bool {
        if case .loaded = self { true } else { false }
    }
}

/// Represents the complete view state for a dynamic list
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct ListViewState<Item: Identifiable & Hashable>: Equatable {
    /// The current loading state
    public let loadingState: LoadingState

    /// The items to display in the list
    public let items: [Item]

    /// Creates a new view state
    /// - Parameters:
    ///   - loadingState: The current loading state
    ///   - items: The items to display
    public init(loadingState: LoadingState, items: [Item]) {
        self.loadingState = loadingState
        self.items = items
    }

    /// Creates an idle state with the given items
    public static func idle(items: [Item] = []) -> Self {
        Self(loadingState: .idle, items: items)
    }

    /// Creates a loading state with the given items (useful for showing previous data while loading new data)
    public static func loading(items: [Item] = []) -> Self {
        Self(loadingState: .loading, items: items)
    }

    /// Creates a loaded state with the given items
    public static func loaded(items: [Item]) -> Self {
        Self(loadingState: .loaded, items: items)
    }

    /// Creates an error state with the given error and items
    public static func error(_ error: Error, items: [Item] = []) -> Self {
        Self(loadingState: .error(error), items: items)
    }
}

// MARK: - Convenience Properties

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public extension ListViewState {
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
