//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Configuration for list appearance and behavior
public struct ListConfiguration {
    /// The style to apply to the list
    public let style: ListStyleType

    /// Whether to hide the navigation bar
    public let navigationBarHidden: Bool

    /// The navigation title for the list
    public let title: String?

    /// Whether to show skeleton view during refresh operations
    public let showSkeletonOnRefresh: Bool

    /// Creates a new ListConfiguration
    /// - Parameters:
    ///   - style: The list style to apply
    ///   - navigationBarHidden: Whether to hide the navigation bar
    ///   - title: The navigation title
    ///   - showSkeletonOnRefresh: Whether to show skeleton during refresh
    public init(
        style: ListStyleType = .automatic,
        navigationBarHidden: Bool = false,
        title: String? = nil,
        showSkeletonOnRefresh: Bool = false,
    ) {
        self.style = style
        self.navigationBarHidden = navigationBarHidden
        self.title = title
        self.showSkeletonOnRefresh = showSkeletonOnRefresh
    }

    /// Creates a configuration with just the style
    /// - Parameter style: The list style to apply
    public static func style(_ style: ListStyleType) -> ListConfiguration {
        ListConfiguration(style: style)
    }

    /// Creates a configuration with just the title
    /// - Parameter title: The navigation title
    public static func title(_ title: String) -> ListConfiguration {
        ListConfiguration(title: title)
    }

    /// Creates a configuration that hides the navigation bar
    public static var hiddenNavigationBar: ListConfiguration {
        ListConfiguration(navigationBarHidden: true)
    }

    /// Creates a configuration that shows skeleton during refresh
    public static var showSkeletonOnRefresh: ListConfiguration {
        ListConfiguration(showSkeletonOnRefresh: true)
    }

    /// Creates a configuration with all default values
    public static var `default`: ListConfiguration {
        ListConfiguration()
    }
}
