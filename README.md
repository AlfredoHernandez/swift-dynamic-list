# 📱 DynamicList


![GitHub last commit](https://img.shields.io/github/last-commit/AlfredoHernandez/swift-dynamic-list?style=for-the-badge)
![issues](https://img.shields.io/github/issues/AlfredoHernandez/swift-dynamic-list?color=blue&style=for-the-badge)
[![GitHub license](https://img.shields.io/github/license/AlfredoHernandez/swift-dynamic-list?color=brigthgreen&style=for-the-badge)](https://github.com/AlfredoHernandez/HackrNews)
![GitHub forks](https://img.shields.io/github/forks/AlfredoHernandez/swift-dynamic-list?style=for-the-badge&color=blueviolet)

A modern and modular SwiftUI library for creating dynamic lists with complete support for reactive data, loading states, advanced search, and multiple list types.

## ✨ Key Features

### 🎯 **Simple and Sectioned Lists**
- **DynamicList**: Traditional lists with flat items
- **SectionedDynamicList**: Lists organized in sections with headers/footers

### 🔄 **Complete Reactivity**
- Native integration with Combine Publishers
- Support for static and reactive data
- Automatic loading state management

### 🎨 **Customizable UI**
- Fully configurable row and detail content
- Customizable error views
- Configurable skeleton loading
- Advanced search with customizable strategies

### 🔍 **Advanced Search System**
- Multiple search strategies (partial, exact, tokenized)
- Search bar placement configuration
- `Searchable` protocol for searchable items
- Customizable strategies

### 🏗️ **Modular Architecture**
- Well-defined public APIs
- Encapsulated private implementation
- Clear separation of responsibilities
- Easy extension and customization

## 🚀 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/AlfredoHernandez/swift-dynamic-list.git", from: "1.0.0")
]
```

### Requirements

- iOS 17.0+
- macOS 14.0+
- watchOS 10.0+
- tvOS 17.0+
- Swift 5.9+

## 📖 Quick Start

### Simple List

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
            .searchable(prompt: "Search users...")
            .build()
    }
}
```

### Sectioned List

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

### Reactive List

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
            .searchable(
                prompt: "Search users...",
                strategy: TokenizedMatchStrategy()
            )
            .build()
    }
}
```

## 🏗️ Modular Architecture

`DynamicList` is organized in a modular MVVM-based architecture that clearly separates responsibilities:

```
Sources/DynamicList/
├── Public/                    # Package public APIs
├── Private/                   # Internal implementations
│   ├── UI/                    # User interface components
│   │   ├── Dynamic List/      # Simple lists
│   │   ├── Sectioned Dynamic List/ # Sectioned lists
│   │   ├── Default Views/     # Default views
│   │   └── Shared/            # Shared components
│   ├── Domain/                # Domain logic
│   │   └── Strategies/        # Search strategies
│   └── Presentation/          # Presentation components
│       └── ViewModels/        # ViewModels with search logic
├── PreviewSupport/            # SwiftUI Previews support
└── Documentation/             # Project documentation
```

### 🎯 **Dynamic List**
- `DynamicList.swift` - Main view
- `DynamicListViewModel.swift` - ViewModel
- `DynamicListBuilder.swift` - Builder pattern
- `DynamicListViewState.swift` - View states
- `SearchConfiguration.swift` - Search configuration

### 📋 **Sectioned Dynamic List**
- `SectionedDynamicList.swift` - Main view
- `SectionedDynamicListViewModel.swift` - ViewModel
- `SectionedDynamicListBuilder.swift` - Builder pattern
- `SectionedListViewState.swift` - View states
- `ListSection.swift` - Data model

### 🔄 **Shared Components**
- `LoadingState.swift` - Shared loading states

### 🔍 **Search Logic in ViewModels**
- **Centralized logic**: Search functionality is implemented in ViewModels
- **Centralized state**: Search text is managed in the ViewModel, not in views
- **Separation of concerns**: Views only handle UI, ViewModels handle filtering logic
- **Background filtering**: Filtering is performed on background threads to keep UI responsive
- **Testability**: Search logic is easily testable in isolation
- **Reusability**: Same search logic for simple and sectioned lists
- **Optimized performance**: Filtering integrated into publisher data flow

### 🎨 **Default Views**
- `DefaultRowView.swift` - Default row view
- `DefaultDetailView.swift` - Default detail view
- `DefaultErrorView.swift` - Default error view
- `DefaultSkeletonView.swift` - Default skeleton loading
- `DefaultSectionedSkeletonView.swift` - Skeleton for sections

## 🎨 Advanced Features

### Optimized Performance

DynamicList includes performance optimizations to handle large volumes of data:

#### Background Filtering
```swift
// Filtering is automatically performed on background threads
DynamicListBuilder<User>()
    .publisher { userService.fetchUsers() } // Data loaded in background
    .searchable(prompt: "Search users...") // Filtering in background
    .build()

// Also works for sectioned lists
SectionedDynamicListBuilder<User>()
    .sections(userSections) // Data loaded in background
    .searchable(prompt: "Search users...") // Filtering in background
    .build()
```

#### Schedulers Separados
- **UI Scheduler**: Para actualizaciones de la interfaz (main queue)
- **IO Scheduler**: Para operaciones de filtrado y procesamiento (background queue)
- **Testing**: Schedulers inmediatos para tests síncronos

#### Flujo de Datos Optimizado
```swift
// Internamente, el flujo es:
Publisher → Background Processing → Filtering → UI Update
```

**Consistencia de Performance**: Tanto `DynamicList` como `SectionedDynamicList` utilizan la misma arquitectura optimizada de filtrado en background, garantizando una experiencia de usuario fluida independientemente del tipo de lista utilizada.

#### Ventajas del Filtrado Automático

**Antes (Manual):**
```swift
// Necesitabas llamar manualmente al método de filtrado
viewModel.updateSearchText("search")  // Método que actualiza estado + filtra (obsoleto)
```

**Después (Automático):**
```swift
// Solo necesitas actualizar el estado, el filtrado es automático
viewModel.searchText = "search"  // didSet dispara el filtrado automáticamente
```

**Beneficios:**
- **Menos código**: No necesitas recordar llamar métodos de filtrado
- **Menos errores**: El filtrado siempre se ejecuta cuando cambia el estado
- **Más intuitivo**: Actualizar el estado es suficiente
- **Mejor performance**: Solo se filtra cuando realmente cambia el valor

#### Gestión del Estado de Búsqueda con Filtrado Automático
```swift
// El estado de búsqueda se maneja completamente en el ViewModel
viewModel.searchText = "texto de búsqueda"  // Estado centralizado + filtrado automático

// Las vistas solo reflejan el estado del ViewModel
.searchable(
    text: Binding(
        get: { viewModel.searchText },      // Leer del ViewModel
        set: { viewModel.searchText = $0 }  // Escribir directamente al ViewModel
    )
)
```

**Filtrado Automático con `didSet`:**
```swift
var searchText: String = "" {
    didSet {
        // Trigger filtering when search text changes
        if oldValue != searchText {
            applySearchFilterOnBackground()
        }
    }
}
```

**Beneficios de la centralización del estado:**
- **Filtrado automático**: El filtrado se dispara automáticamente al cambiar `searchText`
- **Improved testability**: Search state is easily testable
- **Consistency**: Single source of truth for search state
- **Clear separation**: Views only handle UI, ViewModel handles state
- **Reusability**: Same state can be used by multiple views
- **Simplicity**: No need to manually call filtering methods

#### Scheduler Configuration
```swift
// In production (default):
DynamicListViewModel(
    dataProvider: userService.fetchUsers,
    scheduler: .main,                    // UI updates on main queue
    ioScheduler: .global(qos: .userInitiated)  // Background processing
)

// In testing:
DynamicListViewModel(
    dataProvider: testPublisher,
    scheduler: .immediate,               // Synchronous UI updates
    ioScheduler: .immediate              // Synchronous background operations
)
```

### Smart Loading States

```swift
DynamicListBuilder<User>()
    .publisher { userService.fetchUsers() }
    .skeletonContent {
        // Custom skeleton that matches your design
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

### Advanced Search

`DynamicList` includes an advanced search system with multiple strategies:

#### Simple Search

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(prompt: "Search users...")
    .build()
```

#### Search with Custom Strategy

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search users (exact match)...",
        strategy: ExactMatchStrategy()
    )
    .build()
```

#### Search with Custom Predicate

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search by name or email...",
        predicate: { user, query in
            user.name.lowercased().contains(query.lowercased()) ||
            user.email.lowercased().contains(query.lowercased())
        }
    )
    .build()
```

#### Search with Custom Placement

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Search users...",
        placement: .navigationBarDrawer // Always visible
    )
    .build()
```

#### Search in Sectioned Lists

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
- **Optimized performance**: Background thread filtering for responsive UI
- **Scalability**: Efficient handling of large data volumes in sections

#### Available Search Strategies

- **`PartialMatchStrategy`** (default): Case-insensitive partial search
- **`ExactMatchStrategy`**: Case-insensitive exact match
- **`TokenizedMatchStrategy`**: Token/word-based search

#### Available Placement Options

- **`.automatic`** (default): Search bar appears automatically
- **`.navigationBarDrawer`**: Search bar is always visible
- **`.sidebar`**: Search bar appears in sidebar (macOS)
- **`.toolbar`**: Search bar appears in toolbar

#### Searchable Protocol

To use search strategies, your models must conform to `Searchable`:

```swift
struct User: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let email: String
    let role: String
    
    var searchKeys: [String] {
        [name, email, role]
    }
}
```

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

### ViewModel Testing

```swift
import Testing
import DynamicList
import CombineSchedulers

@Suite("DynamicListViewModel Tests")
struct DynamicListViewModelTests {
    
    @Test("when initialized with items displays correct items")
    func test_whenInitializedWithItems_displaysCorrectItems() {
        let items = [TestItem(name: "Test")]
        let viewModel = DynamicListViewModel(
            items: items,
            scheduler: .immediate,      // UI updates
            ioScheduler: .immediate     // Background operations
        )
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
    
    @Test("when data provider sends items updates state")
    func test_whenDataProviderSendsItems_updatesState() {
        let pts = PassthroughSubject<[TestItem], Error>()
        let viewModel = DynamicListViewModel(
            dataProvider: { pts.eraseToAnyPublisher() },
            scheduler: .immediate,      // UI updates
            ioScheduler: .immediate     // Background operations
        )
        
        let items = [TestItem(name: "Updated")]
        pts.send(items)
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
    
    @Test("when search text is updated reflects in view model state")
    func test_whenSearchTextIsUpdated_reflectsInViewModelState() {
        let viewModel = DynamicListViewModel(
            items: [TestItem(name: "Test")],
            scheduler: .immediate,
            ioScheduler: .immediate
        )
        
        // Test initial state
        #expect(viewModel.searchText.isEmpty)
        
        // Test state update
        viewModel.searchText = "search"
        #expect(viewModel.searchText == "search")
        
        // Test state clearing
        viewModel.searchText = ""
        #expect(viewModel.searchText.isEmpty)
    }
    
    @Test("when search text is updated directly triggers automatic filtering")
    func test_whenSearchTextIsUpdatedDirectly_triggersAutomaticFiltering() {
        let viewModel = DynamicListViewModel(
            items: [TestItem(name: "Test")],
            scheduler: .immediate,
            ioScheduler: .immediate
        )
        
        // Test that direct assignment triggers filtering
        viewModel.searchText = "search"  // This triggers didSet automatically
        #expect(viewModel.searchText == "search")
    }
}

### Search Strategy Testing

```swift
import Testing
import DynamicList

@Suite("SearchStrategy Tests")
struct SearchStrategyTests {
    
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
}
```

### Search Logic Testing in ViewModels

```swift
import Testing
import DynamicList

@Suite("SearchViewModel Tests")
struct SearchViewModelTests {
    
    @Test("when search text matches name filters correctly")
    func test_whenSearchTextMatchesName_filtersCorrectly() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User")
        ]
        
        let viewModel = DynamicListViewModel(items: users)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Search users...",
            strategy: PartialMatchStrategy()
        )
        
        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"
        
        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Ana")
    }
    
    @Test("when search text matches items in one section filters correctly")
    func test_whenSearchTextMatchesItemsInOneSection_filtersCorrectly() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")]
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")]
            )
        ]
        
        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Search users...",
            strategy: PartialMatchStrategy()
        )
        
        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"
        
        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].title == "Admins")
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")
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

## 🌍 Localization

`DynamicList` includes complete localization support:

- **English** (en)
- **Mexican Spanish** (es-MX)
- **French** (fr)
- **Portuguese** (pt)

Texts are automatically localized according to the device language.

## 📚 Documentation

- **[🚀 Developer Guide](Sources/DynamicList/Documentation/DeveloperGuide.md)** - Complete developer guide
- **[📁 File Structure](Sources/DynamicList/Documentation/FileStructure.md)** - Project architecture documentation

## 🤝 Contributing

Contributions are welcome. Please read the contribution guidelines before submitting a pull request.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

**DynamicList** - Modern dynamic lists for SwiftUI 🚀 
