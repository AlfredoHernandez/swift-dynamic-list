# 📚 Examples Guide - DynamicList

This guide provides an overview of the comprehensive examples included in the `DynamicList` package, organized by functionality for easy navigation and learning.

## 🎯 Examples Overview

The examples are organized into **6 focused files** that demonstrate different aspects of DynamicList functionality:

### 📁 File Structure

```
Examples/
├── SharedExampleData.swift            # Shared models and sample data
├── BasicListsExample.swift            # Basic lists with static data
├── ReactiveListsExample.swift         # Reactive lists with publishers
├── SectionedListsExample.swift        # Sectioned lists and search
├── ListConfigurationExample.swift     # List configuration and styles
└── AdvancedFeaturesExample.swift      # Advanced features and default views
```

## 🔧 SharedExampleData.swift

**Purpose**: Centralized data models and sample data used across all examples.

### Models Included:
- `Fruit` - Simple model with name, symbol, and color
- `User` - User model with name, email, role, and active status
- `Product` - Product model with name, price, and category
- `Task` - Task model with title, priority, and completion status
- `SearchableUser` - Searchable user model implementing the `Searchable` protocol
- `LoadError` - Error types for demonstration

### Sample Data:
- `fruits` - Collection of fruits with different colors
- `users` - User collection with various roles and statuses
- `products` - Product collection with different categories
- `tasks` - Task collection with different priorities
- `searchableUsers` - Searchable user collection

## 📱 BasicListsExample.swift

**Purpose**: Demonstrates basic list functionality with static data.

### Preview: "Basic Lists - Static Data"

#### Tab 1: Simple List
- **Model**: `Fruit`
- **Features**: Basic list with custom row and detail content
- **Demonstrates**: 
  - Static data usage
  - Custom row layout with symbols and colors
  - Detailed navigation views
  - Basic list styling

#### Tab 2: Users with Actions
- **Model**: `User`
- **Features**: List with custom actions and status indicators
- **Demonstrates**:
  - Custom actions (tap buttons)
  - Status indicators (active/inactive circles)
  - Complex row layouts
  - Detailed user profiles

## 🔄 ReactiveListsExample.swift

**Purpose**: Shows reactive data handling with Combine publishers.

### Preview: "Reactive Lists - Publishers & Error Handling"

#### Tab 1: Reactive Success
- **Model**: `Fruit`
- **Features**: Publisher with simulated delay
- **Demonstrates**:
  - Combine publisher integration
  - Loading states with skeleton views
  - Automatic data updates
  - Success state handling

#### Tab 2: Reactive Error
- **Model**: `Fruit`
- **Features**: Failing publisher with custom error view
- **Demonstrates**:
  - Error handling with custom views
  - Retry functionality
  - Error state management
  - Custom error UI design

## 📋 SectionedListsExample.swift

**Purpose**: Demonstrates sectioned lists and search functionality.

### Preview: "Sectioned Lists & Search"

#### Tab 1: Sectioned List
- **Model**: `Fruit`
- **Features**: Fruits organized by color sections
- **Demonstrates**:
  - Sectioned list creation
  - Dynamic section headers and footers
  - Color-based grouping
  - Section-specific content

#### Tab 2: Searchable List
- **Model**: `SearchableUser`
- **Features**: Searchable user list
- **Demonstrates**:
  - Search functionality
  - `Searchable` protocol implementation
  - Search across multiple fields
  - Real-time filtering

## ⚙️ ListConfigurationExample.swift

**Purpose**: Shows list configuration and styling options.

### Preview: "List Configuration & Styles"

#### Tab 1: Plain Style
- **Model**: `Product`
- **Features**: Products with plain list style
- **Demonstrates**:
  - Different list styles
  - Product layout with prices
  - Plain style appearance
  - Custom detail views

#### Tab 2: Inset Style with Configuration
- **Model**: `Task`
- **Features**: Tasks with inset style and configuration
- **Demonstrates**:
  - `ListConfiguration` usage
  - Inset list style
  - Task completion indicators
  - Configuration-based setup

## 🚀 AdvancedFeaturesExample.swift

**Purpose**: Demonstrates advanced features and default views.

### Preview: "Advanced Features - Optional Details & Default Views"

#### Tab 1: Optional Details
- **Model**: `User`
- **Features**: Conditional navigation based on user status
- **Demonstrates**:
  - `optionalDetailContent` usage
  - Conditional navigation
  - Active/inactive user handling
  - Dynamic detail view creation

#### Tab 2: Default Views Showcase
- **Models**: `User`, `Product`
- **Features**: Default view demonstrations
- **Demonstrates**:
  - `DefaultRowView` usage
  - `DefaultDetailView` usage
  - `DefaultSkeletonView` usage
  - `DefaultErrorView` usage

## 🎯 How to Use Examples

### 1. **Interactive Learning**
Each example includes SwiftUI previews that you can interact with:
- Tap on items to see navigation
- Try search functionality
- Observe loading states
- Test error scenarios

### 2. **Code Reference**
Use examples as reference for your own implementations:
- Copy patterns for similar use cases
- Adapt configurations for your needs
- Use shared models as templates

### 3. **Development Testing**
Examples serve as integration tests:
- Verify functionality works as expected
- Test different configurations
- Validate UI behavior

## 🔍 Example Patterns

### Basic List Pattern
```swift
DynamicListBuilder<Model>()
    .items(staticData)
    .rowContent { item in
        // Custom row layout
    }
    .detailContent { item in
        // Custom detail view
    }
    .build()
```

### Reactive List Pattern
```swift
DynamicListBuilder<Model>()
    .publisher { dataProvider() }
    .rowContent { item in
        // Custom row layout
    }
    .detailContent { item in
        // Custom detail view
    }
    .errorContent { error in
        // Custom error view
    }
    .skeletonContent {
        // Custom loading view
    }
    .build()
```

### Sectioned List Pattern
```swift
SectionedDynamicListBuilder<Model>()
    .sections(sections)
    .rowContent { item in
        // Custom row layout
    }
    .detailContent { item in
        // Custom detail view
    }
    .searchable(prompt: "Search...")
    .build()
```

## 🎨 Customization Examples

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

### Custom Skeleton Loading
```swift
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
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    .redacted(reason: .placeholder)
}
```

## 🧪 Testing with Examples

### Unit Testing
Use examples as test data:
```swift
let testUsers = users // From SharedExampleData
let viewModel = DynamicListViewModel(items: testUsers)
```

### UI Testing
Examples provide realistic test scenarios:
```swift
// Test search functionality
let searchableUsers = searchableUsers // From SharedExampleData
let viewModel = DynamicListViewModel(items: searchableUsers)
```

## 🚀 Best Practices from Examples

### 1. **Use Shared Data**
- Leverage `SharedExampleData.swift` for consistent test data
- Create reusable models for your own examples
- Maintain consistency across different examples

### 2. **Organize by Functionality**
- Group related examples together
- Use descriptive file names
- Include multiple scenarios per example

### 3. **Provide Interactive Previews**
- Use TabView for multiple examples
- Include realistic data
- Demonstrate edge cases

### 4. **Document Patterns**
- Show common usage patterns
- Include customization examples
- Provide copy-paste ready code

## 📚 Related Documentation

- **[Developer Guide](DeveloperGuide.md)** - Complete development guide
- **[DynamicListBuilder](DynamicListBuilder.md)** - Builder pattern documentation
- **[File Structure](FileStructure.md)** - Architecture overview
- **[Combine Integration](CombineIntegration.md)** - Reactive data handling
- **[Custom Error Views](CustomErrorViews.md)** - Error handling guide

---

**Ready to explore?** Start with [BasicListsExample.swift](Examples/BasicListsExample.swift) and work your way through the examples to master DynamicList! 🎉
