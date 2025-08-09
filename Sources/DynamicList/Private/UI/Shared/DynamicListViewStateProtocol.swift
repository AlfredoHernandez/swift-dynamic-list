//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Protocol that defines the common interface for dynamic list view states
protocol DynamicListViewStateProtocol {
    associatedtype Item: Identifiable & Hashable

    /// Returns true if the state is loading
    var isLoading: Bool { get }

    /// Returns the error if there is one
    var error: Error? { get }

    /// Returns true if there is an error
    var hasError: Bool { get }

    /// Returns true if data has been loaded successfully
    var isLoaded: Bool { get }

    /// Returns true if the list is empty
    var isEmpty: Bool { get }

    /// Returns true if should show loading indicator (loading and no items)
    var shouldShowLoading: Bool { get }

    /// Returns true if should show loading indicator with refresh configuration
    /// - Parameter showSkeletonOnRefresh: Whether to show skeleton during refresh
    /// - Returns: True if should show skeleton based on loading state and configuration
    func shouldShowLoading(showSkeletonOnRefresh: Bool) -> Bool

    /// Returns true if should show error state (has error and no items)
    var shouldShowError: Bool { get }

    /// Returns true if should show the list
    var shouldShowList: Bool { get }
}

// MARK: - Default Implementation

extension DynamicListViewStateProtocol {
    var shouldShowLoading: Bool { isLoading && isEmpty }

    func shouldShowLoading(showSkeletonOnRefresh: Bool) -> Bool {
        isLoading && (isEmpty || showSkeletonOnRefresh)
    }

    var shouldShowError: Bool { hasError && isEmpty }
    var shouldShowList: Bool { !isEmpty }
}
