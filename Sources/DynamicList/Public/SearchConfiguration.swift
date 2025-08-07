//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Configuration struct for search functionality in DynamicList.
///
/// This struct encapsulates all search-related properties to simplify
/// initializers and improve code organization.
public struct SearchConfiguration<Item: Identifiable & Hashable> {
    /// Optional prompt text for the search field.
    public let prompt: String?

    /// Optional custom search predicate for filtering items.
    public let predicate: ((Item, String) -> Bool)?

    /// Optional search strategy for Searchable items.
    public let strategy: SearchStrategy?

    /// Placement configuration for the search field.
    public let placement: SearchFieldPlacement

    /// Whether the search bar should be displayed.
    public let isEnabled: Bool

    /// Creates a new SearchConfiguration instance.
    ///
    /// - Parameters:
    ///   - prompt: Optional prompt text for the search field.
    ///   - predicate: Optional custom search predicate for filtering items.
    ///   - strategy: Optional search strategy for Searchable items.
    ///   - placement: Placement configuration for the search field.
    ///   - isEnabled: Whether the search bar should be displayed.
    public init(
        prompt: String? = nil,
        predicate: ((Item, String) -> Bool)? = nil,
        strategy: SearchStrategy? = nil,
        placement: SearchFieldPlacement = .automatic,
        isEnabled: Bool = false,
    ) {
        self.prompt = prompt
        self.predicate = predicate
        self.strategy = strategy
        self.placement = placement
        self.isEnabled = isEnabled
    }

    /// Creates a SearchConfiguration with only a prompt.
    ///
    /// - Parameter prompt: The prompt text for the search field.
    /// - Returns: A SearchConfiguration instance with the specified prompt.
    public static func prompt(_ prompt: String) -> SearchConfiguration<Item> {
        SearchConfiguration(prompt: prompt)
    }

    /// Creates a SearchConfiguration with prompt and placement.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: A SearchConfiguration instance with the specified prompt and placement.
    public static func prompt(_ prompt: String, placement: SearchFieldPlacement) -> SearchConfiguration<Item> {
        SearchConfiguration(prompt: prompt, placement: placement)
    }

    /// Creates a SearchConfiguration with prompt and strategy.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - strategy: The search strategy to use.
    /// - Returns: A SearchConfiguration instance with the specified prompt and strategy.
    public static func prompt(_ prompt: String, strategy: SearchStrategy) -> SearchConfiguration<Item> {
        SearchConfiguration(prompt: prompt, strategy: strategy)
    }

    /// Creates a SearchConfiguration with prompt, strategy, and placement.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - strategy: The search strategy to use.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: A SearchConfiguration instance with the specified parameters.
    public static func prompt(_ prompt: String, strategy: SearchStrategy, placement: SearchFieldPlacement) -> SearchConfiguration<Item> {
        SearchConfiguration(prompt: prompt, strategy: strategy, placement: placement)
    }

    /// Creates a SearchConfiguration with enabled search.
    ///
    /// - Parameters:
    ///   - prompt: Optional prompt text for the search field.
    ///   - predicate: Optional custom search predicate for filtering items.
    ///   - strategy: Optional search strategy for Searchable items.
    ///   - placement: Placement configuration for the search field.
    /// - Returns: A SearchConfiguration instance with search enabled.
    public static func enabled(
        prompt: String? = nil,
        predicate: ((Item, String) -> Bool)? = nil,
        strategy: SearchStrategy? = nil,
        placement: SearchFieldPlacement = .automatic,
    ) -> SearchConfiguration<Item> {
        SearchConfiguration(
            prompt: prompt,
            predicate: predicate,
            strategy: strategy,
            placement: placement,
            isEnabled: true,
        )
    }
}

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
