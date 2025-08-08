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
/// - Note: When `detailContent` is not specified, the list will not provide navigation to detail views.
///   Users can handle custom actions directly in `rowContent` using `Button` or `onTapGesture`.
public final class SectionedDynamicListBuilder<Item: Identifiable & Hashable> {
    // MARK: - Private Properties

    /// Static sections to display in the list
    private var sections: [ListSection<Item>] = []

    /// Combine publisher for reactive data loading
    private var publisher: (() -> AnyPublisher<[[Item]], Error>)?

    /// Custom row content builder
    private var rowContent: ((Item) -> AnyView)?

    /// Custom detail content builder
    private var detailContent: ((Item) -> AnyView?)?

    /// Custom error content builder
    private var errorContent: ((Error) -> AnyView)?

    /// Custom skeleton content builder
    private var skeletonContent: (() -> AnyView)?

    /// Skeleton row configuration for simplified skeleton creation
    private var skeletonRowConfiguration: SectionedSkeletonRowConfiguration?

    /// Search configuration for the list
    private var searchConfiguration: SearchConfiguration<Item>?

    /// List configuration for appearance and behavior
    private var listConfiguration: ListConfiguration = .default

    // MARK: - Private Helper Methods

    /// Updates the list configuration using a transformation closure
    private func updateListConfiguration(_ transform: (ListConfiguration) -> ListConfiguration) -> Self {
        listConfiguration = transform(listConfiguration)
        return self
    }

    /// Updates the search configuration using a transformation closure
    private func updateSearchConfiguration(_ transform: (SearchConfiguration<Item>?) -> SearchConfiguration<Item>?) -> Self {
        searchConfiguration = transform(searchConfiguration)
        return self
    }

    /// Creates a view model based on the current configuration
    private func createViewModel() -> SectionedDynamicListViewModel<Item> {
        if let publisher {
            SectionedDynamicListViewModel(dataProvider: publisher, initialSections: sections)
        } else {
            SectionedDynamicListViewModel(sections: sections)
        }
    }

    /// Creates the shared content view with common configuration
    @MainActor
    private func createContentView(viewModel: SectionedDynamicListViewModel<Item>) -> SectionedDynamicListContent<Item> {
        let finalSkeletonContent: (() -> AnyView)? = if let config = skeletonRowConfiguration {
            {
                AnyView(
                    List {
                        ForEach(0 ..< config.sections, id: \.self) { _ in
                            Section {
                                ForEach(0 ..< config.itemsPerSection, id: \.self) { _ in
                                    config.rowContentBuilder()
                                }
                            } header: {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(height: 20)
                                    .frame(maxWidth: .infinity * 0.5)
                            }
                        }
                    }
                    .modifier(ListStyleModifier(style: config.listStyle))
                    .redacted(reason: .placeholder),
                )
            }
        } else {
            skeletonContent
        }

        return SectionedDynamicListContent(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in AnyView(DefaultRowView(item: item)) },
            detailContent: detailContent,
            errorContent: errorContent,
            skeletonContent: finalSkeletonContent,
            listConfiguration: listConfiguration,
            searchConfiguration: searchConfiguration,
        )
    }

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
    public func publisher(_ publisher: @escaping () -> AnyPublisher<[[Item]], Error>) -> Self {
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
    /// You can return `nil` to disable navigation for specific items.
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

    /// Sets custom detail content with optional navigation.
    ///
    /// Use this method when you want to conditionally enable navigation for specific items.
    /// Return `nil` to disable navigation for items that shouldn't have a detail view.
    ///
    /// - Parameter content: A view builder closure that creates the detail view for each item or returns nil.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .optionalDetailContent { user in
    ///         if user.name == "A" {
    ///             Text("ITEM A")
    ///         } else {
    ///             nil // No navigation for other users
    ///         }
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func optionalDetailContent(_ content: @escaping (Item) -> AnyView?) -> Self {
        detailContent = content
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

    /// Sets custom skeleton content using a single row view for sectioned lists.
    ///
    /// Use this method to provide a single row view that will be repeated to create
    /// a sectioned skeleton loading state. This is more convenient than creating the entire
    /// skeleton list manually.
    ///
    /// - Parameters:
    ///   - sections: The number of sections to display. Defaults to 3.
    ///   - itemsPerSection: The number of items per section. Defaults to 4.
    ///   - content: A view builder that creates a single skeleton row view.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .publisher(apiService.fetchUsersByCategory())
    ///     .skeletonRow(sections: 2, itemsPerSection: 5) {
    ///         HStack {
    ///             Circle()
    ///                 .fill(Color.gray.opacity(0.3))
    ///                 .frame(width: 50, height: 50)
    ///
    ///             VStack(alignment: .leading) {
    ///                 RoundedRectangle(cornerRadius: 4)
    ///                     .fill(Color.gray.opacity(0.3))
    ///                     .frame(height: 20)
    ///                     .frame(maxWidth: .infinity * 0.8)
    ///
    ///                 RoundedRectangle(cornerRadius: 4)
    ///                     .fill(Color.gray.opacity(0.2))
    ///                     .frame(height: 16)
    ///                     .frame(maxWidth: .infinity * 0.6)
    ///             }
    ///
    ///             Spacer()
    ///         }
    ///         .padding(.vertical, 8)
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func skeletonRow(
        sections: Int = 3,
        itemsPerSection: Int = 4,
        @ViewBuilder _ content: @escaping () -> some View,
    ) -> Self {
        skeletonRowConfiguration = SectionedSkeletonRowConfiguration(
            sections: sections,
            itemsPerSection: itemsPerSection,
            listStyle: listConfiguration.style,
            rowContent: content,
        )
        skeletonContent = nil // Clear any existing skeleton content
        return self
    }

    /// Sets the navigation title for the list.
    ///
    /// - Parameter title: The title to display in the navigation bar.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func title(_ title: String) -> Self {
        updateListConfiguration { config in
            ListConfiguration(
                style: config.style,
                navigationBarHidden: config.navigationBarHidden,
                title: title,
            )
        }
    }

    /// Hides the navigation bar.
    ///
    /// Use this method when you want to hide the navigation bar entirely.
    /// Useful for full-screen experiences or when embedding in custom navigation.
    ///
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func hideNavigationBar() -> Self {
        updateListConfiguration { config in
            ListConfiguration(
                style: config.style,
                navigationBarHidden: true,
                title: config.title,
            )
        }
    }

    /// Sets the list style for the list.
    ///
    /// Use this method to customize the appearance of the list with different styles
    /// like `.plain`, `.inset`, `.grouped`, etc.
    ///
    /// - Parameter style: The list style type to apply to the list.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .listStyle(.grouped)
    ///     .build()
    /// ```
    ///
    /// ## Available Styles
    /// - `.automatic` - Default system style
    /// - `.plain` - Simple list without background
    /// - `.inset` - List with inset appearance
    /// - `.grouped` - Grouped list style (iOS only)
    /// - `.insetGrouped` - Inset grouped style (iOS only)
    @discardableResult
    public func listStyle(_ style: ListStyleType) -> Self {
        updateListConfiguration { config in
            ListConfiguration(
                style: style,
                navigationBarHidden: config.navigationBarHidden,
                title: config.title,
            )
        }
    }

    /// Sets the complete list configuration.
    ///
    /// Use this method when you want to set multiple list properties at once.
    ///
    /// - Parameter configuration: The list configuration to apply.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .listConfiguration(ListConfiguration(
    ///         style: .grouped,
    ///         navigationBarHidden: false,
    ///         title: "Users"
    ///     ))
    ///     .build()
    /// ```
    @discardableResult
    public func listConfiguration(_ configuration: ListConfiguration) -> Self {
        listConfiguration = configuration
        return self
    }

    // MARK: - Search Configuration

    /// Enables search functionality with configurable parameters.
    ///
    /// This method provides a unified interface for enabling search functionality with various
    /// configurations. All parameters are optional with sensible defaults.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field. Defaults to "Buscar...".
    ///   - predicate: A closure that determines if an item matches the search text.
    ///                If provided, this overrides the default Searchable protocol behavior.
    ///   - strategy: The search strategy to use for matching when using Searchable items.
    ///               Defaults to PartialMatchStrategy().
    ///   - placement: The placement configuration for the search field.
    ///                Defaults to .automatic.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Examples
    ///
    /// **Basic search with default settings:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable()
    ///     .build()
    /// ```
    ///
    /// **Search with custom prompt:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(prompt: "Buscar usuarios...")
    ///     .build()
    /// ```
    ///
    /// **Search with custom predicate:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar por nombre o email...",
    ///         predicate: { user, searchText in
    ///             user.name.lowercased().contains(searchText.lowercased()) ||
    ///             user.email.lowercased().contains(searchText.lowercased())
    ///         }
    ///     )
    ///     .build()
    /// ```
    ///
    /// **Search with custom strategy:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar usuarios...",
    ///         strategy: TokenizedMatchStrategy()
    ///     )
    ///     .build()
    /// ```
    ///
    /// **Search with custom placement:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar usuarios...",
    ///         placement: .navigationBarDrawer
    ///     )
    ///     .build()
    /// ```
    ///
    /// **Complete custom configuration:**
    /// ```swift
    /// SectionedDynamicListBuilder<User>()
    ///     .sections(sections)
    ///     .searchable(
    ///         prompt: "Buscar por nombre o email...",
    ///         predicate: { user, searchText in
    ///             user.name.lowercased().contains(searchText.lowercased()) ||
    ///             user.email.lowercased().contains(searchText.lowercased())
    ///         },
    ///         placement: .navigationBarDrawer
    ///     )
    ///     .build()
    /// ```
    ///
    /// ## Requirements
    /// - Items should conform to `Searchable` protocol for automatic filtering when no predicate is provided
    /// - If predicate is provided, it takes precedence over the Searchable protocol behavior
    @discardableResult
    public func searchable(
        prompt: String = DynamicListPresenter.searchPrompt,
        predicate: ((Item, String) -> Bool)? = nil,
        strategy: SearchStrategy? = nil,
        placement: SearchFieldPlacement = .automatic,
    ) -> Self {
        searchConfiguration = SearchConfiguration.enabled(
            prompt: prompt,
            predicate: predicate,
            strategy: strategy,
            placement: placement,
        )
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
        updateSearchConfiguration { existingConfig in
            if let config = existingConfig {
                SearchConfiguration.enabled(
                    prompt: config.prompt,
                    predicate: config.predicate,
                    strategy: config.strategy,
                    placement: placement,
                )
            } else {
                SearchConfiguration.enabled(placement: placement)
            }
        }
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
        let viewModel = createViewModel()

        return SectionedDynamicListWrapper(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in AnyView(DefaultRowView(item: item)) },
            detailContent: detailContent,
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            listConfiguration: listConfiguration,
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
        let viewModel = createViewModel()
        return createContentView(viewModel: viewModel)
    }
}
