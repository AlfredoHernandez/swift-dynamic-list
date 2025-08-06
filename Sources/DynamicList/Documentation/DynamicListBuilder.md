# DynamicList Builder

The `DynamicListBuilder` is a class that significantly simplifies the creation of `DynamicList` instances, providing a fluent and easy-to-use API.

## 🎯 Key Features

- **Fluent API**: Builder pattern with chainable methods
- **Flexible Configuration**: Support for different data sources
- **Default Views**: Automatic views when not specified
- **Factory Methods**: Convenience methods for common cases
- **Type Safety**: Completely typed and safe

## 🚀 Basic Usage

### 1. Simple List with Static Data

```swift
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
}

let users = [
    User(name: "Ana", email: "ana@example.com"),
    User(name: "Carlos", email: "carlos@example.com")
]

var body: some View {
    DynamicListBuilder<User>()
        .items(users)
        .title("Users")
        .rowContent { user in
            HStack {
                Text(user.name)
                Spacer()
                Text(user.email)
                    .foregroundColor(.secondary)
            }
        }
        .detailContent { user in
            VStack {
                Text(user.name)
                    .font(.title)
                Text(user.email)
                    .font(.body)
            }
            .navigationTitle("Profile")
        }
        .build()
}
```

### 2. Reactive List with Publisher

```swift
private var usersPublisher: AnyPublisher<[User], Error> {
    // Your publisher here (API, Firebase, etc.)
    return Just(users)
        .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

var body: some View {
    DynamicListBuilder<User>()
        .publisher(usersPublisher)
        .title("Users")
        .rowContent { user in
            Text(user.name)
        }
        .detailContent { user in
            Text("Detail of \(user.name)")
        }
        .build()
}
```

### 3. List with Simulated Loading

```swift
var body: some View {
    DynamicListBuilder<User>()
        .simulatedPublisher(users, delay: 2.0)
        .title("Loading Users")
        .rowContent { user in
            Text(user.name)
        }
        .detailContent { user in
            Text("Detail of \(user.name)")
        }
        .build()
}
```

## 🏭 Factory Methods

### Simple Factory

```swift
var body: some View {
    DynamicListBuilder.simple(
        items: users,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detail of \(user.name)")
        }
    )
}
```

### Reactive Factory

```swift
var body: some View {
    DynamicListBuilder.reactive(
        publisher: usersPublisher,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detail of \(user.name)")
        }
    )
}
```

### Simulated Factory

```swift
var body: some View {
    DynamicListBuilder.simulated(
        items: users,
        delay: 2.0,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detail of \(user.name)")
        }
    )
}
```

## ⚙️ Advanced Configuration

### Custom Error View

```swift
var body: some View {
    DynamicListBuilder<User>()
        .publisher(failingPublisher)
        .errorContent { error in
            VStack {
                Text("😞")
                    .font(.system(size: 60))
                Text("Oops! Something went wrong")
                    .font(.title2)
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                Button("Retry") {
                    // Retry action
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .build()
}
```

### Hide Navigation Bar

```swift
var body: some View {
    DynamicListBuilder<User>()
        .items(users)
        .hideNavigationBar()
        .build()
}
```

## 📊 Comparison: Before vs After

### ❌ Before (Complex)

```swift
// Create ViewModel
let viewModel = DynamicListViewModel(publisher: usersPublisher)

// Create DynamicList with all configuration
DynamicListBuilder<Item>().build()
    viewModel: viewModel,
    rowContent: { user in
        Text(user.name)
    },
    detailContent: { user in
        Text("Detail of \(user.name)")
    }
)
```

### ✅ After (Simple)

```swift
// Single line with builder
DynamicListBuilder<User>()
    .publisher(usersPublisher)
    .rowContent { user in
        Text(user.name)
    }
    .detailContent { user in
        Text("Detail of \(user.name)")
    }
    .build()
```

## 🎨 Default Views

If you don't specify `rowContent` or `detailContent`, the builder provides default views:

### Default Row View
```swift
VStack(alignment: .leading) {
    Text("\(item)")
        .font(.body)
    Text("ID: \(item.id)")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

### Default Detail View
```swift
VStack(spacing: 16) {
    Text("Item Detail")
        .font(.largeTitle)
        .fontWeight(.bold)
    
    Text("\(item)")
        .font(.body)
    
    Text("ID: \(item.id)")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

## 🔧 Available Methods

### Data Configuration
- `items(_:)` - Static data
- `publisher(_:)` - Combine publisher
- `simplePublisher(_:)` - Simple publisher
- `simulatedPublisher(_:delay:)` - Publisher with loading simulation

### UI Configuration
- `rowContent(_:)` - Row content
- `detailContent(_:)` - Detail content
- `errorContent(_:)` - Custom error view
- `title(_:)` - Navigation title
- `hideNavigationBar()` - Hide navigation bar

### Factory Methods
- `simple(items:rowContent:detailContent:)` - Simple list
- `reactive(publisher:rowContent:detailContent:)` - Reactive list
- `simulated(items:delay:rowContent:detailContent:)` - List with simulation

## 🎯 Benefits

1. **Less Code**: Significant reduction in lines of code
2. **More Readable**: Fluent and expressive API
3. **Fewer Errors**: Type safety and automatic validations
4. **More Flexible**: Optional configuration and defaults
5. **Faster**: Faster development with less boilerplate

## 🚀 Common Use Cases

### Product List with API
```swift
DynamicListBuilder<Product>()
    .publisher(apiService.fetchProducts())
    .title("Products")
    .rowContent { product in
        ProductRowView(product: product)
    }
    .detailContent { product in
        ProductDetailView(product: product)
    }
    .build()
```

### User List with Firebase
```swift
DynamicListBuilder<User>()
    .publisher(firebaseService.usersPublisher())
    .title("Users")
    .rowContent { user in
        UserRowView(user: user)
    }
    .detailContent { user in
        UserProfileView(user: user)
    }
    .build()
```

### Simple List for Testing
```swift
DynamicListBuilder.simple(
    items: testData,
    rowContent: { item in
        Text(item.name)
    },
    detailContent: { item in
        Text("Test: \(item.name)")
    }
)
```

The `DynamicListBuilder` makes creating dynamic lists as simple as chaining methods! 🎉

## ⚠️ Important Note: Navigation

### Nested NavigationStack Problem

If you experience navigation issues (such as unexpected "pop" from the stack), you likely have nested `NavigationStack`s. This happens when:

1. You already have a `NavigationStack` in the parent context
2. The `DynamicListBuilder` creates its own internal `NavigationStack`

### Solution

Use `buildWithoutNavigation()` when you already have navigation in the parent context:

```swift
// ❌ Incorrect - Nested NavigationStacks
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .build() // This creates another NavigationStack
}

// ✅ Correct - Single NavigationStack
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .buildWithoutNavigation() // Doesn't create additional NavigationStack
}
```

### When to Use Each Method

- **`build()`**: When the `DynamicListBuilder` is the root view or there's no existing navigation
- **`buildWithoutNavigation()`**: When there's already a `NavigationStack` in the parent context

## 🆕 Modern Solution: NavigationStack(path:)

### Nested Navigation Problem

When you have a list of examples that navigates to other lists, each with its own `NavigationStack`, you can experience strange behaviors:

```swift
// ❌ Problem: Nested NavigationStacks
NavigationStack {
    List {
        NavigationLink("Example") {
            DynamicListBuilder<User>() // Has its own NavigationStack
                .items(users)
                .build()
        }
    }
}
```

### Solution with NavigationStack(path:)

`NavigationStack(path:)` is the modern solution that allows handling multiple navigation levels without creating nested stacks:

```swift
// ✅ Modern solution - NavigationStack(path:) with enum
enum BuilderExample: Hashable {
    case simpleList
    case reactiveList
    case customError
}

struct BuilderExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Simple List", value: BuilderExample.simpleList)
                NavigationLink("Reactive List", value: BuilderExample.reactiveList)
                NavigationLink("Custom Error", value: BuilderExample.customError)
            }
            .navigationDestination(for: BuilderExample.self) { example in
                switch example {
                case .simpleList:
                    DynamicListBuilder<User>()
                        .items(users)
                        .buildWithoutNavigation() // No internal NavigationStack
                case .reactiveList:
                    DynamicListBuilder<Product>()
                        .publisher(publisher)
                        .buildWithoutNavigation() // No internal NavigationStack
                case .customError:
                    DynamicListBuilder<User>()
                        .publisher(failingPublisher)
                        .buildWithoutNavigation() // No internal NavigationStack
                }
            }
        }
    }
}
```

### Example with Factory Methods

```swift
// ✅ Factory Examples also uses NavigationStack(path:)
enum FactoryExample: Hashable {
    case simpleFactory
    case reactiveFactory
    case simulatedFactory
}

struct FactoryExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Simple Factory", value: FactoryExample.simpleFactory)
                NavigationLink("Reactive Factory", value: FactoryExample.reactiveFactory)
                NavigationLink("Simulated Factory", value: FactoryExample.simulatedFactory)
            }
            .navigationDestination(for: FactoryExample.self) { example in
                switch example {
                case .simpleFactory:
                    SimpleFactoryExample()
                case .reactiveFactory:
                    ReactiveFactoryExample()
                case .simulatedFactory:
                    SimulatedFactoryExample()
                }
            }
        }
    }
}
```

### Advantages of NavigationStack(path:)

- ✅ **No nested NavigationStacks** - Avoids strange behaviors
- ✅ **Smooth navigation** - Smooth transitions between views
- ✅ **Total control** - Programmatic handling of navigation stack
- ✅ **Compatibility** - Works perfectly with DynamicListBuilder
- ✅ **Scalability** - Easy to add more navigation levels

### When to Use NavigationStack(path:)

- **Example lists** that navigate to other lists
- **Navigation menus** with multiple levels
- **Complex flows** that require stack control
- **Modern apps** that use iOS 16+ and SwiftUI NavigationStack

### Solution Comparison

| Method | Advantages | Disadvantages | Recommended Use |
|--------|------------|---------------|-----------------|
| `build()` | Simple, direct | May create nested stacks | Main views |
| `buildWithoutNavigation()` | Avoids nested stacks | Requires external navigation | Inside NavigationStack |
| `NavigationStack(path:)` | Total control, no issues | More initial code | Example lists, complex flows | 