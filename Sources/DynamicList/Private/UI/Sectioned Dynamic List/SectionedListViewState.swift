//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Represents the complete view state for a sectioned dynamic list
struct SectionedListViewState<Item: Identifiable & Hashable>: Equatable, DynamicListViewStateProtocol {
    /// The current loading state
    let loadingState: LoadingState

    /// The sections to display in the list
    let sections: [ListSection<Item>]

    /// Creates a new sectioned view state
    /// - Parameters:
    ///   - loadingState: The current loading state
    ///   - sections: The sections to display
    init(loadingState: LoadingState, sections: [ListSection<Item>]) {
        self.loadingState = loadingState
        self.sections = sections
    }

    /// Creates an idle state with the given sections
    static func idle(sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .idle, sections: sections)
    }

    /// Creates a loading state with the given sections (useful for showing previous data while loading new data)
    static func loading(sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .loading, sections: sections)
    }

    /// Creates a loaded state with the given sections
    static func loaded(sections: [ListSection<Item>]) -> Self {
        Self(loadingState: .loaded, sections: sections)
    }

    /// Creates an error state with the given error and sections
    static func error(_ error: Error, sections: [ListSection<Item>] = []) -> Self {
        Self(loadingState: .error(error), sections: sections)
    }

    /// Convenience initializer from array of arrays
    static func fromArrays(_ arrays: [[Item]], titles: [String?] = []) -> Self {
        let sections = zip(arrays, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        return Self(loadingState: .loaded, sections: sections)
    }
}

// MARK: - Convenience Properties

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
