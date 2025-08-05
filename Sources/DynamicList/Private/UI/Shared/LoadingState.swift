//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

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
