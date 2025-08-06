# 📱 DynamicList

![GitHub last commit](https://img.shields.io/github/last-commit/AlfredoHernandez/swift-dynamic-list?style=for-the-badge)
![issues](https://img.shields.io/github/issues/AlfredoHernandez/swift-dynamic-list?color=blue&style=for-the-badge)
[![GitHub license](https://img.shields.io/github/license/AlfredoHernandez/swift-dynamic-list?color=brigthgreen&style=for-the-badge)](https://github.com/AlfredoHernandez/swift-dynamic-list)
![GitHub forks](https://img.shields.io/github/forks/AlfredoHernandez/swift-dynamic-list?style=for-the-badge&color=blueviolet)

A modern SwiftUI library for creating dynamic lists with reactive data, loading states, and advanced search capabilities.

## ✨ Features

- **Simple & Sectioned Lists** - Create both flat and sectioned lists
- **Reactive Data** - Native Combine integration with automatic state management
- **Advanced Search** - Built-in search with customizable strategies
- **Loading States** - Automatic skeleton loading and error handling
- **Fluent API** - Builder pattern for easy configuration
- **Cross-Platform** - iOS, macOS, watchOS, tvOS support

## 🚀 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/AlfredoHernandez/swift-dynamic-list.git", from: "1.0.0")
]
```

### Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+
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

### Reactive List with API

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
            .searchable(prompt: "Search users...")
            .build()
    }
}
```

## 🎨 Advanced Features

### Custom Search Strategies

```swift
// Exact match search
.searchable(
    prompt: "Search users (exact match)...",
    strategy: ExactMatchStrategy()
)

// Token-based search
.searchable(
    prompt: "Search users...",
    strategy: TokenizedMatchStrategy()
)
```

### Custom Error Views

```swift
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
        
        Button("Retry") {
            // Retry logic
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}
```

### Factory Methods

```swift
// Simple static list
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
```

## 🔍 Searchable Models

To use search features, make your models conform to `Searchable`:

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

## 🌍 Localization

Supports English, Spanish, French, and Portuguese with automatic localization.

## 📚 Documentation

- **[Developer Guide](Sources/DynamicList/Documentation/DeveloperGuide.md)** - Complete guide
- **[File Structure](Sources/DynamicList/Documentation/FileStructure.md)** - Architecture details

## 🤝 Contributing

Contributions are welcome! Please read the contribution guidelines before submitting a pull request.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

**DynamicList** - Modern dynamic lists for SwiftUI 🚀 
