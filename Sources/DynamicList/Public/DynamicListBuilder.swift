//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

/// A fluent builder class that simplifies the creation of DynamicList instances.
///
/// This builder provides a clean, chainable API for configuring and creating dynamic lists
/// with support for static data, reactive publishers, custom UI components, and error handling.
///
/// ## Basic Usage
/// ```swift
/// DynamicListBuilder<User>()
///     .items(users)
///     .rowContent { user in
///         Text(user.name)
///     }
///     .detailContent { user in
///         UserDetailView(user: user)
///     }
///     .build()
/// ```
///
///
/// ## Reactive Data Source
/// ```swift
/// DynamicListBuilder<Product>()
///     .publisher(apiService.fetchProducts())
///     .title("Productos")
///     .rowContent { product in
///         ProductRowView(product: product)
///     }
///     .detailContent { product in
///         ProductDetailView(product: product)
///     }
///     .build()
/// ```
///
/// ## Factory Methods (Simplified)
/// ```swift
/// // Simple static list
/// DynamicListBuilder.simple(
///     items: users,
///     rowContent: { user in Text(user.name) },
///     detailContent: { user in Text("Detalle de \(user.name)") }
/// )
///
/// // Reactive list
/// DynamicListBuilder.reactive(
///     publisher: apiService.fetchProducts(),
///     rowContent: { product in ProductRowView(product: product) },
///     detailContent: { product in ProductDetailView(product: product) }
/// )
/// ```
///
/// - Note: The `Item` type must conform to `Identifiable` and `Hashable` protocols.
/// - Important: Use `build()` for standalone lists or `buildWithoutNavigation()` when embedding
///   within existing navigation contexts to avoid NavigationStack conflicts.
/// - Note: When `detailContent` is not specified, the list will not provide navigation to detail views.
///   Users can handle custom actions directly in `rowContent` using `Button` or `onTapGesture`.
public final class DynamicListBuilder<Item: Identifiable & Hashable> {
    // MARK: - Private Properties

    /// Static items to display in the list
    private var items: [Item] = []

    /// Combine publisher for reactive data loading
    private var publisher: (() -> AnyPublisher<[Item], Error>)?

    /// Custom row content builder
    private var rowContent: ((Item) -> AnyView)?

    /// Custom detail content builder
    private var detailContent: ((Item) -> AnyView?)?

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

    /// Creates a new DynamicListBuilder instance.
    ///
    /// Use this initializer to start building a dynamic list configuration.
    /// All configuration is done through the fluent API methods.
    public init() {}

    // MARK: - Data Source Configuration

    /// Sets static items for the list.
    ///
    /// Use this method when you have a fixed array of items that don't need to be loaded
    /// from an external source. The items will be displayed immediately without any loading state.
    ///
    /// - Parameter items: The array of items to display in the list.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(User.sampleUsers)
    ///     .build()
    /// ```
    @discardableResult
    public func items(_ items: [Item]) -> Self {
        self.items = items
        return self
    }

    /// Sets a Combine publisher as the reactive data source.
    ///
    /// Use this method when you need to load data from external sources like APIs,
    /// databases, or any service that returns a Combine publisher. The list will
    /// automatically handle loading states, errors, and data updates.
    ///
    /// - Parameter publisher: A closure that returns a Combine publisher that emits arrays of items.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<Product>()
    ///     .publisher { apiService.fetchProducts() }
    ///     .build()
    /// ```
    ///
    /// ## Publisher Requirements
    /// - Must emit `[Item]` arrays
    /// - Must handle errors appropriately
    /// - Should complete after emitting data
    @discardableResult
    public func publisher(_ publisher: @escaping () -> AnyPublisher<[Item], Error>) -> Self {
        self.publisher = publisher
        return self
    }

    /// Sets a simple publisher that emits a single array of items.
    ///
    /// This is a convenience method that wraps static items in a publisher.
    /// Useful when you want to use the reactive infrastructure but have static data.
    ///
    /// - Parameter items: The array of items to emit via the publisher.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .simplePublisher(User.sampleUsers)
    ///     .build()
    /// ```
    @discardableResult
    public func simplePublisher(_ items: [Item]) -> Self {
        publisher = {
            Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return self
    }

    /// Sets a publisher that simulates loading with a configurable delay.
    ///
    /// Useful for testing, demos, or when you want to simulate network delays
    /// to show loading states in your UI.
    ///
    /// - Parameters:
    ///   - items: The array of items to emit after the delay.
    ///   - delay: The delay in seconds before emitting the items. Defaults to 1.0 second.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .simulatedPublisher(User.sampleUsers, delay: 2.0)
    ///     .build()
    /// ```
    @discardableResult
    public func simulatedPublisher(_ items: [Item], delay: TimeInterval = 1.0) -> Self {
        publisher = {
            Just(items)
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return self
    }

    // MARK: - UI Configuration

    /// Sets the custom row content builder.
    ///
    /// Use this method to customize how each item is displayed in the list.
    /// If not provided, a default row view will be used that shows the item's description.
    ///
    /// - Parameter content: A view builder closure that creates the row view for each item.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .rowContent { user in
    ///         HStack {
    ///             AsyncImage(url: user.avatarURL) { image in
    ///                 image.resizable()
    ///             } placeholder: {
    ///                 Circle().fill(.gray)
    ///             }
    ///             .frame(width: 40, height: 40)
    ///             .clipShape(Circle())
    ///
    ///             VStack(alignment: .leading) {
    ///                 Text(user.name)
    ///                     .font(.headline)
    ///                 Text(user.email)
    ///                     .font(.caption)
    ///                     .foregroundColor(.secondary)
    ///             }
    ///         }
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func rowContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        rowContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets the custom detail content builder.
    ///
    /// Use this method to customize the detail view that appears when a user taps on a list item.
    /// If not provided, a default detail view will be used that shows the item's description.
    /// You can return `nil` to disable navigation for specific items.
    ///
    /// - Parameter content: A view builder closure that creates the detail view for each item.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .detailContent { user in
    ///         if user.isActive {
    ///             VStack(spacing: 16) {
    ///                 AsyncImage(url: user.avatarURL) { image in
    ///                     image.resizable()
    ///                 } placeholder: {
    ///                     Circle().fill(.gray)
    ///                 }
    ///                 .frame(width: 100, height: 100)
    ///                 .clipShape(Circle())
    ///
    ///                 Text(user.name)
    ///                     .font(.title)
    ///                     .fontWeight(.bold)
    ///
    ///                 Text(user.email)
    ///                     .font(.body)
    ///
    ///                 Text(user.bio)
    ///                     .font(.body)
    ///                     .foregroundColor(.secondary)
    ///             }
    ///             .padding()
    ///         } else {
    ///             nil // No navigation for inactive users
    ///         }
    ///     }
    ///     .build()
    /// ```
    @discardableResult
    public func detailContent(@ViewBuilder _ content: @escaping (Item) -> some View) -> Self {
        detailContent = { item in
            AnyView(content(item))
        }
        return self
    }

    /// Sets the custom detail content builder with optional navigation.
    ///
    /// Use this method when you want to conditionally enable navigation for specific items.
    /// Return `nil` to disable navigation for items that shouldn't have a detail view.
    ///
    /// - Parameter content: A view builder closure that creates the detail view for each item or returns nil.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
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

    /// Sets a custom error view for handling loading failures.
    ///
    /// Use this method to provide a custom error view when data loading fails.
    /// If not provided, a default error view will be used that shows a generic error message.
    ///
    /// - Parameter content: A view builder closure that creates the error view.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .publisher(failingPublisher)
    ///     .errorContent { error in
    ///         VStack(spacing: 16) {
    ///             Image(systemName: "exclamationmark.triangle")
    ///                 .font(.system(size: 50))
    ///                 .foregroundColor(.orange)
    ///
    ///             Text("Error al cargar usuarios")
    ///                 .font(.headline)
    ///
    ///             Text(error.localizedDescription)
    ///                 .font(.body)
    ///                 .foregroundColor(.secondary)
    ///                 .multilineTextAlignment(.center)
    ///
    ///             Button("Reintentar") {
    ///                 // Retry logic
    ///             }
    ///             .buttonStyle(.borderedProminent)
    ///         }
    ///         .padding()
    ///     }
    ///     .build()
    /// ```
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
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .publisher(apiService.fetchUsers())
    ///     .skeletonContent {
    ///         List(0..<5, id: \.self) { _ in
    ///             HStack {
    ///                 Circle()
    ///                     .fill(Color.gray.opacity(0.3))
    ///                     .frame(width: 50, height: 50)
    ///
    ///                 VStack(alignment: .leading) {
    ///                     RoundedRectangle(cornerRadius: 4)
    ///                         .fill(Color.gray.opacity(0.3))
    ///                         .frame(height: 20)
    ///                         .frame(maxWidth: .infinity * 0.8)
    ///
    ///                     RoundedRectangle(cornerRadius: 4)
    ///                         .fill(Color.gray.opacity(0.2))
    ///                         .frame(height: 16)
    ///                         .frame(maxWidth: .infinity * 0.6)
    ///                 }
    ///
    ///                 Spacer()
    ///             }
    ///             .padding(.vertical, 8)
    ///         }
    ///         .redacted(reason: .placeholder)
    ///     }
    ///     .build()
    /// ```
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
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .title("Usuarios")
    ///     .build()
    /// ```
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
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .hideNavigationBar()
    ///     .build()
    /// ```
    @discardableResult
    public func hideNavigationBar() -> Self {
        navigationBarHidden = true
        return self
    }

    // MARK: - Search Configuration

    /// Enables search functionality with a custom prompt.
    ///
    /// Use this method to add search capability to the list. The search field will appear
    /// in the navigation bar and filter items based on the Searchable protocol or custom predicate.
    ///
    /// - Parameter prompt: The placeholder text for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(prompt: "Buscar usuarios...")
    ///     .build()
    /// ```
    ///
    /// ## Requirements
    /// - Items should conform to `Searchable` protocol for automatic filtering
    /// - Or use `searchable(prompt:predicate:)` for custom search logic
    @discardableResult
    public func searchable(prompt: String) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt)
        return self
    }

    /// Enables search functionality with a prompt and placement.
    ///
    /// Use this method to enable search functionality with Searchable items using the default
    /// PartialMatchStrategy and control the search field placement.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(
    ///         prompt: "Buscar usuarios...",
    ///         placement: .navigationBarDrawer
    ///     )
    ///     .build()
    /// ```
    ///
    /// ## Requirements
    /// - Items should conform to `Searchable` protocol for automatic filtering
    /// - Or use `searchable(prompt:predicate:placement:)` for custom search logic
    @discardableResult
    public func searchable(
        prompt: String,
        placement: SearchFieldPlacement,
    ) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt, placement: placement)
        return self
    }

    /// Enables search functionality with custom search logic.
    ///
    /// Use this method when you need custom search behavior that goes beyond the Searchable protocol.
    /// The predicate receives the item and search text, and should return true if the item matches.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field.
    ///   - predicate: A closure that determines if an item matches the search text.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(
    ///         prompt: "Buscar por nombre o email...",
    ///         predicate: { user, searchText in
    ///             user.name.lowercased().contains(searchText.lowercased()) ||
    ///             user.email.lowercased().contains(searchText.lowercased())
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

    /// Enables search functionality with custom search logic and placement.
    ///
    /// Use this method when you need custom search behavior that goes beyond the Searchable protocol
    /// and want to control the search field placement.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field.
    ///   - predicate: A closure that determines if an item matches the search text.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
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

    /// Enables search functionality with a custom search strategy.
    ///
    /// Use this method when you want to use a specific search strategy with Searchable items.
    /// The strategy determines how the search query is matched against the item's search keys.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field.
    ///   - strategy: The search strategy to use for matching.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(
    ///         prompt: "Buscar usuarios...",
    ///         strategy: TokenizedMatchStrategy()
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

    /// Enables search functionality with a custom search strategy and placement.
    ///
    /// Use this method when you want to use a specific search strategy with Searchable items
    /// and control the search field placement.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text for the search field.
    ///   - strategy: The search strategy to use for matching.
    ///   - placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(
    ///         prompt: "Buscar usuarios...",
    ///         strategy: TokenizedMatchStrategy(),
    ///         placement: .navigationBarDrawer
    ///     )
    ///     .build()
    /// ```
    @discardableResult
    public func searchable(
        prompt: String,
        strategy: SearchStrategy,
        placement: SearchFieldPlacement,
    ) -> Self {
        searchConfiguration = SearchConfiguration.prompt(prompt, strategy: strategy, placement: placement)
        return self
    }

    /// Configures the search field placement.
    ///
    /// Use this method to control when and where the search field is displayed.
    ///
    /// - Parameter placement: The placement configuration for the search field.
    /// - Returns: The builder instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchable(prompt: "Buscar usuarios...")
    ///     .searchPlacement(.navigationBarDrawer) // Always visible
    ///     .build()
    /// ```
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
    /// DynamicListBuilder<User>()
    ///     .items(users)
    ///     .searchConfiguration(searchConfig)
    ///     .build()
    /// ```
    @discardableResult
    public func searchConfiguration(_ configuration: SearchConfiguration<Item>) -> Self {
        searchConfiguration = configuration
        return self
    }

    // MARK: - Build Methods

    /// Builds a complete DynamicList with NavigationStack.
    ///
    /// This method creates a fully functional dynamic list wrapped in its own NavigationStack.
    /// Use this when you want a standalone list that manages its own navigation.
    ///
    /// - Returns: A SwiftUI view containing the configured dynamic list.
    ///
    /// ## Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         DynamicListBuilder<User>()
    ///             .items(users)
    ///             .title("Usuarios")
    ///             .build()
    ///     }
    /// }
    /// ```
    ///
    /// - Important: Don't use this method when embedding the list within an existing NavigationStack
    ///   to avoid navigation conflicts. Use `buildWithoutNavigation()` instead.
    @MainActor
    public func build() -> some View {
        let viewModel: DynamicListViewModel<Item> = if let publisher {
            DynamicListViewModel(dataProvider: publisher, initialItems: items)
        } else {
            DynamicListViewModel(items: items)
        }

        return DynamicListWrapper(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent,
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
            searchConfiguration: searchConfiguration,
        )
    }

    /// Builds a DynamicList without NavigationStack for embedding in existing navigation.
    ///
    /// Use this method when you want to embed the list within an existing NavigationStack
    /// or when you need to manage navigation at a higher level. This prevents navigation
    /// conflicts and allows for more flexible navigation patterns.
    ///
    /// - Returns: A SwiftUI view containing the configured dynamic list without navigation wrapper.
    ///
    /// ## Example
    /// ```swift
    /// struct ExamplesView: View {
    ///     @State private var navigationPath = NavigationPath()
    ///
    ///     var body: some View {
    ///         NavigationStack(path: $navigationPath) {
    ///             List {
    ///                 NavigationLink("Users", value: "users")
    ///                 NavigationLink("Products", value: "products")
    ///             }
    ///             .navigationDestination(for: String.self) { destination in
    ///                 switch destination {
    ///                 case "users":
    ///                     DynamicListBuilder<User>()
    ///                         .items(users)
    ///                         .buildWithoutNavigation()
    ///                 case "products":
    ///                     DynamicListBuilder<Product>()
    ///                         .items(products)
    ///                         .buildWithoutNavigation()
    ///                 default:
    ///                     EmptyView()
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Important: When using this method, ensure that the parent view provides the necessary
    ///   navigation context and handles `navigationDestination` appropriately.
    @MainActor
    public func buildWithoutNavigation() -> some View {
        let viewModel: DynamicListViewModel<Item> = if let publisher {
            DynamicListViewModel(dataProvider: publisher, initialItems: items)
        } else {
            DynamicListViewModel(items: items)
        }

        return DynamicListContent(
            viewModel: viewModel,
            rowContent: rowContent ?? { item in
                AnyView(DefaultRowView(item: item))
            },
            detailContent: detailContent,
            errorContent: errorContent,
            skeletonContent: skeletonContent,
            title: title,
            navigationBarHidden: navigationBarHidden,
            searchConfiguration: searchConfiguration,
        )
    }
}

// MARK: - Convenience Factory Methods

/// Convenience factory methods for common use cases.
///
/// These static methods provide simplified ways to create common list configurations
/// without needing to use the full builder API. They're perfect for quick prototypes
/// or simple use cases.
public extension DynamicListBuilder {
    /// Creates a simple list with static items using a minimal API.
    ///
    /// This factory method is perfect for quick prototypes or when you have static data
    /// and want to get up and running quickly with minimal configuration.
    ///
    /// - Parameters:
    ///   - items: The array of items to display in the list.
    ///   - rowContent: A view builder that creates the row view for each item.
    ///   - detailContent: A view builder that creates the detail view for each item.
    /// - Returns: A configured dynamic list view without navigation wrapper.
    ///
    /// ## Example
    /// ```swift
    /// struct SimpleListView: View {
    ///     var body: some View {
    ///         DynamicListBuilder.simple(
    ///             items: User.sampleUsers,
    ///             rowContent: { user in
    ///                 Text(user.name)
    ///             },
    ///             detailContent: { user in
    ///                 Text("Detalle de \(user.name)")
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor
    static func simple(
        title: String = "",
        items: [Item],
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .title(title)
            .items(items)
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }

    /// Creates a reactive list with a publisher data source using a minimal API.
    ///
    /// This factory method is perfect for lists that need to load data from external
    /// sources like APIs or databases. It automatically handles loading states and errors.
    ///
    /// - Parameters:
    ///   - publisher: A Combine publisher that emits arrays of items.
    ///   - rowContent: A view builder that creates the row view for each item.
    ///   - detailContent: A view builder that creates the detail view for each item.
    /// - Returns: A configured dynamic list view without navigation wrapper.
    ///
    /// ## Example
    /// ```swift
    /// struct ReactiveListView: View {
    ///     var body: some View {
    ///         DynamicListBuilder.reactive(
    ///             publisher: apiService.fetchProducts(),
    ///             rowContent: { product in
    ///                 ProductRowView(product: product)
    ///             },
    ///             detailContent: { product in
    ///                 ProductDetailView(product: product)
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor
    static func reactive(
        publisher: AnyPublisher<[Item], Error>,
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .publisher { publisher }
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }

    /// Creates a list with simulated loading for testing and demos.
    ///
    /// This factory method is perfect for testing loading states, creating demos,
    /// or when you want to simulate network delays to show loading UI.
    ///
    /// - Parameters:
    ///   - items: The array of items to display after the loading delay.
    ///   - delay: The delay in seconds before showing the items. Defaults to 1.0 second.
    ///   - rowContent: A view builder that creates the row view for each item.
    ///   - detailContent: A view builder that creates the detail view for each item.
    /// - Returns: A configured dynamic list view without navigation wrapper.
    ///
    /// ## Example
    /// ```swift
    /// struct DemoListView: View {
    ///     var body: some View {
    ///         DynamicListBuilder.simulated(
    ///             items: User.sampleUsers,
    ///             delay: 2.0,
    ///             rowContent: { user in
    ///                 Text(user.name)
    ///             },
    ///             detailContent: { user in
    ///                 Text("Detalle de \(user.name)")
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    @MainActor
    static func simulated(
        items: [Item],
        delay: TimeInterval = 1.0,
        @ViewBuilder rowContent: @escaping (Item) -> some View,
        @ViewBuilder detailContent: @escaping (Item) -> some View,
    ) -> some View {
        DynamicListBuilder<Item>()
            .simulatedPublisher(items, delay: delay)
            .rowContent(rowContent)
            .detailContent(detailContent)
            .buildWithoutNavigation()
    }
}
