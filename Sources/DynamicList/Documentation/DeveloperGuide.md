# 🚀 Developer Guide - DynamicList

This guide is designed for developers who want to integrate **DynamicList** into their SwiftUI projects effectively and following best practices.

## 🎯 Key Features

- **📱 Dynamic Lists**: Complete support for lists with static and reactive data
- **🔄 Reactivity**: Native integration with Combine Publishers
- **⚡ Loading States**: Automatic handling of loading, error and success states
- **🎨 Customizable UI**: Fully configurable row, detail and error content
- **🔄 Pull-to-Refresh**: Integrated reload functionality
- **🧭 Navigation**: Automatic navigation to detail views
- **📋 Sections**: Support for lists with multiple sections and headers/footers
- **💀 Skeleton Loading**: Loading states with configurable placeholders
- **🔍 Advanced Search**: Search system with multiple strategies
- **🏗️ Modular Architecture**: Well-defined public APIs with encapsulated private implementation

## 🏗️ Project Architecture

`DynamicList` is organized in a modular architecture that clearly separates responsibilities:

### 📁 Component Structure

```
Sources/DynamicList/
├── Public/                    # Package public APIs
├── Private/                   # Internal implementations
│   ├── UI/                    # User interface components
│   │   ├── Dynamic List/      # Components for simple lists
│   │   ├── Sectioned Dynamic List/ # Components for sectioned lists
│   │   ├── Default Views/     # Default views
│   │   └── Shared/            # Shared components
│   ├── Domain/                # Domain logic
│   │   └── Strategies/        # Search strategies
│   └── Presentation/          # Presentation components
├── PreviewSupport/            # SwiftUI Previews support
└── Documentation/             # Project documentation
```

### 🎯 Public APIs

#### **DynamicListBuilder**
Main API for creating simple dynamic lists:

```swift
import DynamicList

// Direct usage
DynamicListBuilder<User>()
    .items(users)
    .rowContent { user in UserRowView(user: user) }
    .detailContent { user in UserDetailView(user: user) }
    .build()

// With Factory Methods
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detail of \(user.name)") }
)
```

#### **SectionedDynamicListBuilder**
API for creating dynamic lists with sections:

```swift
import DynamicList

// With explicit sections
SectionedDynamicListBuilder<Fruit>()
    .sections([
        ListSection(title: "Red", items: redFruits),
        ListSection(title: "Green", items: greenFruits)
    ])
    .rowContent { fruit in FruitRowView(fruit: fruit) }
    .detailContent { fruit in FruitDetailView(fruit: fruit) }
    .build()

// With arrays of arrays
SectionedDynamicListBuilder<Fruit>()
    .groupedItems([redFruits, greenFruits], titles: ["Red", "Green"])
    .rowContent { fruit in FruitRowView(fruit: fruit) }
    .detailContent { fruit in FruitDetailView(fruit: fruit) }
    .build()
```

## 🚀 Quick Start

### Installation

Add `DynamicList` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/DynamicList.git", from: "1.0.0")
]
```

### Basic Usage - Simple List

```swift
import SwiftUI
import DynamicList

struct ContentView: View {
    let users = [
        User(id: "1", name: "Ana", email: "ana@example.com"),
        User(id: "2", name: "Bob", email: "bob@example.com")
    ]
    
    var body: some View {
        DynamicListBuilder<User>()
            .items(users)
            .rowContent { user in
                HStack {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .detailContent { user in
                VStack(spacing: 20) {
                    Text(user.name)
                        .font(.largeTitle)
                    Text(user.email)
                        .font(.title2)
                }
            }
            .title("Users")
            .build()
    }
}
```

### Basic Usage - Sectioned List

```swift
struct SectionedContentView: View {
    let sections = [
        ListSection(
            title: "Administrators",
            items: adminUsers,
            footer: "\(adminUsers.count) administrators"
        ),
        ListSection(
            title: "Users",
            items: regularUsers,
            footer: "\(regularUsers.count) users"
        )
    ]
    
    var body: some View {
        SectionedDynamicListBuilder<User>()
            .sections(sections)
            .rowContent { user in
                HStack {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .detailContent { user in
                UserDetailView(user: user)
            }
            .title("Users by Role")
            .searchable(prompt: "Search users...")
            .build()
    }
}
```

## 🔄 Combine Integration

### Simple Reactive List

```swift
struct ReactiveListView: View {
    var body: some View {
        DynamicListBuilder<User>()
            .publisher { userService.fetchUsers() }
            .rowContent { user in UserRowView(user: user) }
            .detailContent { user in UserDetailView(user: user) }
            .errorContent { error in
                VStack {
                    Text("Error: \(error.localizedDescription)")
                    Button("Retry") { /* retry logic */ }
                }
            }
            .skeletonContent {
                // Custom skeleton
                List(0..<5, id: \.self) { _ in
                    UserSkeletonRow()
                }
            }
            .build()
    }
}
```

### Sectioned List with Publisher

```swift
struct ReactiveSectionedListView: View {
    var body: some View {
        SectionedDynamicListBuilder<User>()
            .publisher { userService.fetchUsersByRole() }
            .rowContent { user in UserRowView(user: user) }
            .detailContent { user in UserDetailView(user: user) }
            .skeletonContent {
                DefaultSectionedSkeletonView()
            }
            .build()
    }
}
```

## 🎨 Advanced Customization

### Custom Error Views

```swift
DynamicListBuilder<User>()
    .publisher { userService.fetchUsers() }
    .errorContent { error in
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Connection Error")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                // Retry logic
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    .build()
```

### Custom Skeleton Loading

```swift
DynamicListBuilder<User>()
    .publisher { userService.fetchUsers() }
    .skeletonContent {
        List(0..<8, id: \.self) { _ in
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity * 0.8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(maxWidth: .infinity * 0.6)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .redacted(reason: .placeholder)
    }
    .build()
```

## 🔍 Advanced Search System

`DynamicList` includes an advanced search system that allows multiple search strategies and complete customization.

### Searchable Protocol

To enable search in your models, conform to the `Searchable` protocol:

```swift
struct User: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let email: String
    let role: String
    let department: String
    
    var searchKeys: [String] {
        [name, email, role, department]
    }
}
```

### Available Search Strategies

#### PartialMatchStrategy (Default)

Case-insensitive partial search. Searches for the query within any search key:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(prompt: "Search users...")
    .build()
```

#### ExactMatchStrategy

Case-insensitive exact match. Requires the query to exactly match a key:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search users (exact match)...",
        strategy: ExactMatchStrategy()
    )
    .build()
```

#### TokenizedMatchStrategy

Token/word-based search. Splits the query into words and searches for all to be present:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search by words...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

### Search with Custom Predicate

For completely custom search logic:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search by name or email...",
        predicate: { user, query in
            let searchLower = query.lowercased()
            return user.name.lowercased().contains(searchLower) ||
                   user.email.lowercased().contains(searchLower) ||
                   user.role.lowercased().contains(searchLower)
        }
    )
    .build()
```

### Search with Custom Placement

To control when and where the search bar appears:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search users...",
        placement: .navigationBarDrawer // Always visible
    )
    .build()
```

### Combining Strategy and Placement

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search users...",
        strategy: TokenizedMatchStrategy(),
        placement: .navigationBarDrawer
    )
    .build()
```

### Search in Sectioned Lists

```swift
SectionedDynamicListBuilder<User>()
    .sections(sections)
    .searchable(
        prompt: "Search users...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

Search in sectioned lists works intelligently:

- **Section filtering**: Only sections containing matching items are shown
- **Structure preservation**: Headers and footers of sections with results are maintained
- **Global search**: Search is applied to all items across all sections
- **Same API**: Uses the same search methods as simple lists

### Available Placement Options

- **`.automatic`** (default): Search bar appears automatically when user scrolls
- **`.navigationBarDrawer`**: Search bar is always visible in navigation bar
- **`.sidebar`**: Search bar appears in sidebar (macOS)
- **`.toolbar`**: Search bar appears in toolbar

### Use Cases by Placement

#### `.navigationBarDrawer` - Always Visible Search
Ideal for long lists where search is a primary functionality:

```swift
DynamicListBuilder<Contact>()
    .items(contacts)
    .searchable(
        prompt: "Search contacts...",
        placement: .navigationBarDrawer
    )
    .build()
```

#### `.automatic` - Automatic Search
Perfect for lists where search is secondary:

```swift
DynamicListBuilder<Product>()
    .items(products)
    .searchable(
        prompt: "Search products...",
        placement: .automatic
    )
    .build()
```

### Custom Strategies

You can create your own search strategies:

```swift
struct FuzzyMatchStrategy: SearchStrategy {
    func matches(query: String, in item: Searchable) -> Bool {
        let queryLower = query.lowercased()
        return item.searchKeys.contains { key in
            // Implement fuzzy search logic
            key.lowercased().contains(queryLower) ||
            key.lowercased().fuzzyMatch(queryLower)
        }
    }
}

// Usage
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Fuzzy search...",
        strategy: FuzzyMatchStrategy()
    )
    .build()
```

### Common Use Cases

#### Search in Product Lists

```swift
struct Product: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let category: String
    let tags: [String]
    let price: Double
    
    var searchKeys: [String] {
        [name, category] + tags + [String(format: "%.2f", price)]
    }
}

DynamicListBuilder<Product>()
    .items(products)
    .searchable(
        prompt: "Search products...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

#### Search in Contact Lists

```swift
struct Contact: Identifiable, Hashable, Searchable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let company: String
    
    var searchKeys: [String] {
        [firstName, lastName, email, phone, company]
    }
}

DynamicListBuilder<Contact>()
    .items(contacts)
    .searchable(
        prompt: "Search contacts...",
        strategy: PartialMatchStrategy()
    )
    .build()
```

## 🧪 Testing

### Test Naming Convention

Use the `test_whenCondition_expectedBehavior()` convention for all tests:

```swift
@Test("when initialized with items displays correct items")
func test_whenInitializedWithItems_displaysCorrectItems() {
    // Test implementation
}

@Test("when data provider fails shows error state")
func test_whenDataProviderFails_showsErrorState() {
    // Test implementation
}
```

### Unit Tests

```swift
import Testing
import DynamicList
import CombineSchedulers

@Suite("DynamicListViewModel Tests")
struct DynamicListViewModelTests {
    
    @Test("when initialized with items displays correct items")
    func test_whenInitializedWithItems_displaysCorrectItems() {
        let items = [TestItem(name: "Test")]
        let viewModel = DynamicListViewModel(items: items)
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
    
    @Test("when data provider sends items updates state")
    func test_whenDataProviderSendsItems_updatesState() {
        let pts = PassthroughSubject<[TestItem], Error>()
        let viewModel = DynamicListViewModel(
            dataProvider: { pts.eraseToAnyPublisher() },
            scheduler: .immediate
        )
        
        let items = [TestItem(name: "Updated")]
        pts.send(items)
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
}
```

### UI Tests

```swift
import Testing
import SwiftUI
import DynamicList

@Suite("DynamicList Tests")
struct DynamicListTests {
    
    @Test("when initialized with items creates list view with correct items")
    func test_whenInitializedWithItems_createsListViewWithCorrectItems() {
        let items = [TestItem(name: "Test")]
        let viewModel = DynamicListViewModel(items: items)
        
        let sut = DynamicListBuilder<TestItem>().build()
            viewModel: viewModel,
            rowContent: { item in Text(item.name) },
            detailContent: { item in Text(item.name) }
        )
        
        // Use Mirror to inspect internal state
        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let itemsFromMirror = viewModelFromMirror?.wrappedValue.viewState.items
        
        #expect(itemsFromMirror == items)
    }
}
```

### Search Strategy Testing

```swift
import Testing
import DynamicList

// Test model for Searchable
struct TestSearchableItem: Searchable {
    let id = UUID()
    let name: String
    let description: String
    let tags: [String]
    
    var searchKeys: [String] {
        [name, description] + tags
    }
}

@Suite("SearchStrategy Tests")
struct SearchStrategyTests {
    
    // Tests for PartialMatchStrategy
    @Test("when query matches name returns true")
    func test_whenQueryMatchesName_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query is empty returns true")
    func test_whenQueryIsEmpty_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "Test Item",
            description: "A test description",
            tags: ["tag1", "tag2"]
        )
        
        let result = strategy.matches(query: "", in: item)
        
        #expect(result == true)
    }
    
    // Tests for ExactMatchStrategy
    @Test("when query exactly matches name returns true")
    func test_whenQueryExactlyMatchesName_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone 15 Pro", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query is partial match returns false")
    func test_whenQueryIsPartialMatch_returnsFalse() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone", in: item)
        
        #expect(result == false)
    }
    
    // Tests for TokenizedMatchStrategy
    @Test("when all query tokens match returns true")
    func test_whenAllQueryTokensMatch_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"]
        )
        
        let result = strategy.matches(query: "iPhone Pro", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query tokens match across different keys returns true")
    func test_whenQueryTokensMatchAcrossDifferentKeys_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"]
        )
        
        let result = strategy.matches(query: "iPhone advanced", in: item)
        
        #expect(result == true)
    }
    
    // Tests for edge cases
    @Test("when searchable item has empty search keys returns false")
    func test_whenSearchableItemHasEmptySearchKeys_returnsFalse() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "",
            description: "",
            tags: []
        )
        
        let result = strategy.matches(query: "test", in: item)
        
        #expect(result == false)
    }
}
```

## 🔧 Advanced Configuration

### Embedding in Existing Navigation

```swift
struct AppView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Users", value: "users")
                NavigationLink("Products", value: "products")
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "users":
                    DynamicListBuilder<User>()
                        .items(users)
                        .buildWithoutNavigation()
                case "products":
                    DynamicListBuilder<Product>()
                        .items(products)
                        .buildWithoutNavigation()
                default:
                    EmptyView()
                }
            }
        }
    }
}
```

### Factory Methods

```swift
// Static simple list
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detail of \(user.name)") }
)

// Reactive list
DynamicListBuilder.reactive(
    publisher: userService.fetchUsers(),
    rowContent: { user in UserRowView(user: user) },
    detailContent: { user in UserDetailView(user: user) }
)

// List with loading simulation
DynamicListBuilder.simulated(
    items: users,
    delay: 2.0,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detail of \(user.name)") }
)
```

## 🎯 Best Practices

### 1. **Choose the Right List Type**
- **DynamicList**: For simple lists without grouping
- **SectionedDynamicList**: For lists with categories or sections

### 2. **Use the Builder Pattern**
- More readable and maintainable
- Fluent and chainable API
- Automatic default configuration

### 3. **Handle Loading States**
- Provide custom skeleton loading
- Handle errors gracefully
- Use pull-to-refresh for reloads

### 4. **Optimize Performance**
- Use `Identifiable` and `Hashable` in your models
- Implement `Equatable` for SwiftUI optimizations
- Consider lazy loading for large lists

### 5. **Implement Effective Search**
- Conform to `Searchable` in your models
- Choose the appropriate search strategy
- Consider search bar placement

### 6. **Complete Testing**
- Use the `test_whenCondition_expectedBehavior()` naming convention
- Test ViewModels with `CombineSchedulers.immediate`
- Include tests for search strategies

## 🆘 Troubleshooting

### Common Issues

#### 1. **Compilation Error: "Cannot find type"**
- Make sure to import `DynamicList`
- Verify that the `Item` type conforms to `Identifiable` and `Hashable`

#### 2. **Search doesn't work**
- Verify that your model conforms to `Searchable`
- Implement `searchKeys` correctly
- Make sure search keys are not empty

#### 3. **Tests fail**
- Use `CombineSchedulers.immediate` for synchronous tests
- Verify that publishers complete correctly
- Make sure states change as expected

#### 4. **Navigation issues**
- Use `buildWithoutNavigation()` when embedding in existing navigation
- Verify there are no NavigationStack conflicts

### Debugging

#### 1. **Verify States**
```swift
.onReceive(viewModel.$viewState) { state in
    print("ViewState changed: \(state)")
}
```

#### 2. **Search Debugging**
```swift
.onReceive($searchText) { query in
    print("Search query: '\(query)'")
}
```

#### 3. **Verify Data**
```swift
.onReceive(viewModel.$items) { items in
    print("Items updated: \(items.count) items")
}
```

## 📚 Additional Resources

- **[File Structure](FileStructure.md)** - Architecture documentation
- **[Code Examples](PreviewSupport/)** - Complete and functional examples
- **[Tests](Tests/)** - Testing examples and best practices

---

**Ready to start?** Begin with a [simple list](#basic-usage---simple-list) and then move to [reactive data](#combine-integration).

Happy coding! 🎉 