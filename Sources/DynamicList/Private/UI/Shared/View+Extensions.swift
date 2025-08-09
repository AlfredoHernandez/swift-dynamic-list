//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - View Extension for Conditional Search

extension View {
    /// Applies searchable modifier conditionally based on SearchConfiguration.
    ///
    /// - Parameters:
    ///   - searchConfiguration: The search configuration to apply.
    ///   - text: Binding to the search text.
    /// - Returns: A view with conditional search functionality.
    func conditionalSearchable(_ searchConfiguration: SearchConfiguration<some Identifiable & Hashable>?, text: Binding<String>) -> some View {
        if let searchConfiguration, searchConfiguration.isEnabled {
            return AnyView(
                searchable(
                    text: text,
                    placement: searchConfiguration.placement,
                    prompt: searchConfiguration.prompt ?? DynamicListPresenter.searchPrompt,
                ),
            )
        } else {
            return AnyView(self)
        }
    }
}

// MARK: - View Extension for Conditional iOS Navigation

extension View {
    /// Applies navigation bar hidden modifier conditionally for iOS platform.
    ///
    /// - Parameter isHidden: Whether to hide the navigation bar.
    /// - Returns: A view with conditional navigation bar visibility.
    func conditionalNavigationBarHidden(_ isHidden: Bool) -> some View {
        #if os(iOS)
        return AnyView(navigationBarHidden(isHidden))
        #else
        return AnyView(self)
        #endif
    }
}
