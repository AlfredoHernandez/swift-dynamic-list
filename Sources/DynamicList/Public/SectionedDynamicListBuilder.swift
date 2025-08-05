//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

/// A fluent builder class that simplifies the creation of SectionedDynamicList instances.
///
/// This builder provides a clean, chainable API for configuring and creating sectioned dynamic lists
/// with support for static data, reactive publishers, custom UI components, and error handling.
///
/// ## Basic Usage
/// ```swift
/// SectionedDynamicListBuilder<Fruit>()
///     .sections([
///         ListSection(title: "Frutas Rojas", items: redFruits),
///         ListSection(title: "Frutas Verdes", items: greenFruits)
///     ])
///     .rowContent { fruit in
///         Text(fruit.name)
///     }
///     .detailContent { fruit in
///         FruitDetailView(fruit: fruit)
///     }
///     .build()
/// ```
///
/// ## Reactive Data Source
/// ```swift
/// SectionedDynamicListBuilder<Fruit>()
///     .publisher(apiService.fetchFruitsByCategory())
///     .title("Frutas por Categoría")
///     .rowContent { fruit in
///         FruitRowView(fruit: fruit)
///     }
///     .detailContent { fruit in
///         FruitDetailView(fruit: fruit)
///     }
///     .build()
/// ```
///
/// - Note: The `Item` type must conform to `Identifiable` and `Hashable` protocols.
/// - Important: Use `build()` for standalone lists or `buildWithoutNavigation()` when embedding
///   within existing navigation contexts to avoid NavigationStack conflicts.
public final class SectionedDynamicListBuilder<Item: Identifiable & Hashable> {
    // MARK: - Private Properties

    /// Static sections to display in the list
    private var sections: [ListSection<Item>] = []

    /// Combine publisher for reactive data loading
    private var publisher: AnyPublisher<[[Item]], Error>?

    /// Custom row content builder
    private var rowContent: ((Item) -> AnyView)?

    /// Custom detail content builder
    private var detailContent: ((Item) -> AnyView)?

    /// Custom error content builder
    private var errorContent: ((Error) -> AnyView)?

    /// Custom skeleton content builder
    private var skeletonContent: (() -> AnyView)?

    /// Navigation title for the list
    private var title: String?

    /// Whether to hide the navigation bar
    private var navigationBarHidden: Bool = false

    /// Search configuration for the list
    private var searchConfiguration: SearchConfiguration<Item>?

    // MARK: - Initialization

    /// Creates a new SectionedDynamicListBuilder instance.
    ///
    /// Use this initializer to start building a sectioned dynamic list configuration.
    /// All configuration is done through the fluent API methods.
    public init() {}

    // MARK: - Data Source Configuration

    /// Sets static sections for the list.
    ///
    /// Use this method when you have a fixed array of sections that don't need to be loaded
    /// from an external source. The sections will be displayed immediately without any loading state.
    ///
    /// - Parameter sections: The sections to display in the list.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<Fruit>()
    ///     .sections([
    ///         ListSection(title: "Frutas Rojas", items: redFruits),
    ///         ListSection(title: "Frutas Verdes", items: greenFruits)
    ///     ])
    ///     .rowContent { fruit in
    ///         Text(fruit.name)
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func sections(_ sections: [ListSection<Item>]) -> Self {
        self.sections = sections
        return self
    }

    /// Sets grouped items for the list with optional section titles.
    ///
    /// Use this method when you have arrays of arrays representing sections with optional titles.
    ///
    /// - Parameters:
    ///   - groupedItems: Array of arrays representing sections
    ///   - titles: Optional titles for each section
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<Fruit>()
    ///     .groupedItems([redFruits, greenFruits, yellowFruits], titles: ["Rojas", "Verdes", "Amarillas"])
    ///     .rowContent { fruit in
    ///         Text(fruit.name)
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func groupedItems(_ groupedItems: [[Item]], titles: [String?] = []) -> Self {
        let sections = zip(groupedItems, titles).map { items, title in
            ListSection(title: title, items: items)
        }
        self.sections = sections
        return self
    }

    /// Sets a Combine publisher for reactive data loading.
    ///
    /// Use this method when you want to load data from an external source like an API,
    /// database, or any other reactive data stream. The publisher should emit arrays of arrays.
    /// The list will automatically handle loading states, error handling, and data updates.
    ///
    /// - Parameter publisher: A Combine publisher that emits arrays of arrays.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<Fruit>()
    ///     .publisher(apiService.fetchFruitsByCategory())
    ///     .rowContent { fruit in
    ///         FruitRowView(fruit: fruit)
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func publisher(_ publisher: AnyPublisher<[[Item]], Error>) -> Self {
        self.publisher = publisher
        return self
    }

    // MARK: - Content Configuration

    /// Sets custom row content for each item in the list.
    ///
    /// This method allows you to define how each item should be displayed in the list.
    /// The content builder receives the item and should return a SwiftUI view.
    ///
    /// - Parameter content: A view builder that creates the row view for each item.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func rowContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        rowContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets custom detail content for when an item is selected.
    ///
    /// This method allows you to define the detail view that will be displayed when
    /// a user taps on an item in the list. The content builder receives the selected item.
    ///
    /// - Parameter content: A view builder that creates the detail view for an item.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func detailContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        detailContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets custom error content for when loading fails.
    ///
    /// This method allows you to define a custom error view that will be displayed
    /// when the data loading fails. The content builder receives the error that occurred.
    ///
    /// - Parameter content: A view builder that creates the error view.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func errorContent(@ViewBuilder _ content: @escaping (Error) -> some View) -> Self {
        errorContent = { error in
            AnyView(content(error))
        }
        return self
    }

    /// Sets custom skeleton content for the loading state.
    ///
    /// Use this method to provide a custom skeleton view that will be displayed when the list
    /// is in a loading state with no items available. This allows you to create skeleton
    /// layouts that match your actual content structure.
    ///
    /// - Parameter content: A view builder that creates the skeleton view.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func skeletonContent(@ViewBuilder _ content: @escaping () -> some View) -> Self {
        skeletonContent = {
            AnyView(content())
        }
        return self
    }

    /// Sets the navigation title for the list.
    ///
    /// - Parameter title: The title to display in the navigation bar.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    /// Hides the navigation bar.
    ///
    /// Use this method when you want to hide the navigation bar entirely.
    /// Useful for full-screen experiences or when embedding in custom navigation.
    ///
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func hideNavigationBar() -> Self {
        navigationBarHidden = true
        return self
    }

    // MARK: - Search Configuration

    /// Enables search functionality with a simple prompt.
    ///
    /// This method enables search functionality using the default partial match strategy.
    /// The search will work with items that conform to `Searchable` protocol.
    ///
    /// - Parameter prompt: The prompt text for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(prompt: "Buscar usuarios...")
    ///     .build()
    /// ```
    @discardableResult
    public func searchable(prompt: String) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt)
        return self
    }

    /// Enables search functionality with prompt and placement configuration.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func searchable(
        prompt: String,
        placement: SearchFieldPlacement,
    ) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt, placement: placement)
        return self
    }

    /// Enables search functionality with a custom predicate.
    ///
    /// Use this method when you want to implement custom search logic that doesn't rely
    /// on the `Searchable` protocol or when you need more control over the search behavior.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - predicate: A closure that determines if an item matches the search query.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar por nombre o email...",
    ///         predicate: { user, query in
    ///             user.name.lowercased().contains(query.lowercased()) ||
    ///             user.email.lowercased().contains(query.lowercased())
    ///         }
    ///     )
    ///     .build()
    /// ```
    @discardableResult
    public func searchable(
        prompt: String,
        predicate: @escaping (Item, String) -> Bool,
    ) -> Self {
        searchConfiguration = SearchConfiguration(
            prompt: prompt,
            predicate: predicate,
        )
        return self
    }

    /// Enables search functionality with a custom predicate and placement.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - predicate: A closure that determines if an item matches the search query.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func searchable(
        prompt: String,
        predicate: @escaping (Item, String) -> Bool,
        placement: SearchFieldPlacement,
    ) -> Self {
        searchConfiguration = SearchConfiguration(
            prompt: prompt,
            predicate: predicate,
            placement: placement,
        )
        return self
    }

    /// Enables search functionality with a custom strategy.
    ///
    /// Use this method when you want to use a specific search strategy with items that
    /// conform to the `Searchable` protocol.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - strategy: The search strategy to use for matching items.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar usuarios (coincidencia exacta)...",
    ///         strategy: ExactMatchStrategy()
    ///     )
    ///     .build()
    /// ```
    @discardableResult
    public func searchable(
        prompt: String,
        strategy: SearchStrategy,
    ) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt, strategy: strategy)
        return self
    }

    /// Enables search functionality with a custom strategy and placement.
    ///
    /// - Parameters:
    ///   - prompt: The prompt text for the search field.
    ///   - strategy: The search strategy to use for matching items.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func searchable(
        prompt: String,
        strategy: SearchStrategy,
        placement: SearchFieldPlacement,
    ) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt, strategy: strategy, placement: placement)
        return self
    }

    /// Sets the search placement configuration.
    ///
    /// Use this method to configure where the search field appears without changing
    /// other search settings. If no search configuration exists, this will create one
    /// with default settings.
    ///
    /// - Parameter placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func searchPlacement(_ placement: SearchFieldPlacement) -> Self {
        if let existingConfig = searchConfiguration {
            searchConfiguration = SearchConfiguration(
                prompt: existingConfig.prompt,
                predicate: existingConfig.predicate,
                strategy: existingConfig.strategy,
                placement: placement,
            )
        } else {
            searchConfiguration = SearchConfiguration(placement: placement)
        }
        return self
    }

    /// Sets the search configuration directly.
    ///
    /// Use this method when you want to set the complete search configuration
    /// at once, rather than using individual search methods.
    ///
    /// - Parameter configuration: The search configuration to use.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let searchConfig = SearchConfiguration<User>(
    ///     prompt: "Buscar usuarios...",
    ///     strategy: TokenizedMatchStrategy(),
    ///     placement: .automatic
    /// )
    ///
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchConfiguration(searchConfig)
    ///     .build()
    /// ```
    @discardableResult
    public func searchConfiguration(_ configuration: SearchConfiguration<Item>) -> Self {
        searchConfiguration = configuration
        return self
    }

    // MARK: - Build Methods

    /// Builds a complete SectionedDynamicList with NavigationStack.
    ///
    /// This method creates a fully functional sectioned dynamic list wrapped in its own NavigationStack.
    /// Use this when you want a standalone list that manages its own navigation.
    ///
    /// - Returns: A SwiftUI view containing the configured sectioned dynamic list.
    @MainActor
    public func build() -> some View {
        let viewModel: SectionedDynamicListViewModel<Item> = if let publisher {
            SectionedDynamicListViewModel(dataProvider: { publisher }, initialSections: sections)
        } else {
            SectionedDynamicListViewModel(sections: sections)
        }

        return SectionedDynamicListWrapper(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent ?? { item in
                AnyView(DefaultDetailView(item: item))
            },
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
            searchConfiguration: searchConfiguration,
        )
    }

    /// Builds a SectionedDynamicList without NavigationStack for embedding in existing navigation.
    ///
    /// Use this method when you want to embed the list within an existing NavigationStack
    /// or when you need to manage navigation at a higher level. This prevents navigation
    /// conflicts and allows for more flexible navigation patterns.
    ///
    /// - Returns: A SwiftUI view containing the configured sectioned dynamic list without navigation wrapper.
    @MainActor
    public func buildWithoutNavigation() -> some View {
        let viewModel: SectionedDynamicListViewModel<Item> = if let publisher {
            SectionedDynamicListViewModel(dataProvider: { publisher }, initialSections: sections)
        } else {
            SectionedDynamicListViewModel(sections: sections)
        }

        return SectionedDynamicListContent(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent ?? { item in
                AnyView(DefaultDetailView(item: item))
            },
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
            searchConfiguration: searchConfiguration,
        )
    }
}
