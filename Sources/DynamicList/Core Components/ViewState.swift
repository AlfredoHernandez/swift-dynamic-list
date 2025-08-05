//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents the loading state of a dynamic list
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

/// Represents a section in a list with optional header and footer
public struct ListSection<Item: Identifiable & Hashable>: Identifiable, Hashable {
    public let id = UUID()
    public let title: String?
    public let items: [Item]
    public let footer: String?

    public init(title: String? = nil, items: [Item], footer: String? = nil) {
        self.title = title
        self.items = items
        self.footer = footer
    }

    public static func == (lhs: ListSection<Item>, rhs: ListSection<Item>) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Represents the complete view state for a dynamic list
struct ListViewState<Item: Identifiable & Hashable>: Equatable {
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

/// Represents the complete view state for a sectioned dynamic list
public struct SectionedListViewState<Item: Identifiable & Hashable>: Equatable {
    /// The current loading state
    public let loadingState: LoadingState

    /// The sections to display in the list
    public let sections: [ListSection<Item>]

    /// Creates a new sectioned view state
    /// - Parameters:
    ///   - loadingState: The current loading state
    ///   - sections: The sections to display
    public init(loadingState: LoadingState, sections: [ListSection<Item>]) {
        self.loadingState = loadingState
        self.sections = sections
    }

    /// Creates an idle state with the given sections
    public static func idle(sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .idle, sections: sections)
    }

    /// Creates a loading state with the given sections (useful for showing previous data while loading new data)
    public static func loading(sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .loading, sections: sections)
    }

    /// Creates a loaded state with the given sections
    public static func loaded(sections: [ListSection<Item>]) -> Self {
        Self(loadingState: .loaded, sections: sections)
    }

    /// Creates an error state with the given error and sections
    public static func error(_ error: Error, sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .error(error), sections: sections)
    }

    /// Convenience initializer from array of arrays
    public static func fromArrays(_ arrays: [[Item]], titles: [String?] = []) -> Self {
        let sections = zip(arrays, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        return Self(loadingState: .loaded, sections: sections)
    }
}

// MARK: - Convenience Properties

extension ListViewState {
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

extension SectionedListViewState {
    /// Returns true if the state is loading
    var isLoading: Bool { loadingState.isLoading }

    /// Returns the error if there is one
    var error: Error? { loadingState.error }

    /// Returns true if there is an error
    var hasError: Bool { loadingState.hasError }

    /// Returns true if data has been loaded successfully
    var isLoaded: Bool { loadingState.isLoaded }

    /// Returns true if the list is empty (no sections or all sections empty)
    var isEmpty: Bool { sections.isEmpty || sections.allSatisfy(\.items.isEmpty) }

    /// Returns true if should show loading indicator (loading and no items)
    var shouldShowLoading: Bool { isLoading && isEmpty }

    /// Returns true if should show error state (has error and no items)
    var shouldShowError: Bool { hasError && isEmpty }

    /// Returns true if should show the list
    var shouldShowList: Bool { !isEmpty }

    /// Returns all items flattened from all sections
    var allItems: [Item] { sections.flatMap(\.items) }
}
