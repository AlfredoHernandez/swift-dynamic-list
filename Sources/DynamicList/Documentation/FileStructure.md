# 📁 File Structure

This documentation describes the file organization of the `DynamicList` package and how the different components are structured.

## 🏗️ General Structure

```
DynamicList/
├── Sources/
│   └── DynamicList/
│       ├── Public/                    # Public APIs of the package
│       ├── Private/                   # Internal implementations
│       │   ├── UI/                    # User interface components
│       │   │   ├── Dynamic List/      # Components for simple lists
│       │   │   ├── Sectioned Dynamic List/ # Components for sectioned lists
│       │   │   └── Shared/            # Shared components
│       │   ├── Domain/                # Domain logic
│       │   └── Presentation/          # Presentation components
│       ├── Examples/                  # SwiftUI Examples and Previews
│       └── Documentation/             # Project documentation
└── Tests/
    └── DynamicListTests/              # Unit and UI tests
```

## 📋 Public APIs

### 🎯 DynamicListBuilder
Main public API for creating simple dynamic lists.

```
Public/
└── DynamicListBuilder.swift           # Builder pattern for simple lists
```

**Features:**
- Fluent and chainable API
- Support for static and reactive data
- Advanced search configuration
- Complete UI customization
  - Factory methods for common cases

### 📋 SectionedDynamicListBuilder
Public API for creating dynamic lists with sections.

```
Public/
└── SectionedDynamicListBuilder.swift  # Builder pattern for sectioned lists
```

**Features:**
- Fluent API for sectioned lists
- Support for arrays of arrays `[[Item]]`
- Headers and footers per section
- Same functionality as simple lists

### 🔍 SearchConfiguration
Public API for configuring search functionality.

```
Public/
└── SearchConfiguration.swift          # Search configuration builder
```

**Features:**
- Configurable search strategies
- Customizable search behavior
- Integration with both list types

### 🎨 ListStyleType
Public API for list styling options.

```
Public/
└── ListStyleType.swift                # List style configuration
```

**Features:**
- Predefined list styles
- Customizable appearance options

### 🔍 Search Strategies
Public search strategy implementations.

```
Public/Search Strategies/
├── PartialMatchStrategy.swift         # Partial search (default)
├── ExactMatchStrategy.swift           # Exact match search
└── TokenizedMatchStrategy.swift       # Token-based search
```

**Features:**
- Multiple search algorithms
- Customizable search behavior
- Easy integration with lists

### 🎨 Default Views
Public default view implementations.

```
Public/Default Views/
├── DefaultRowView.swift               # Default row view
├── DefaultDetailView.swift            # Default detail view
├── DefaultErrorView.swift             # Default error view
├── DefaultSkeletonView.swift          # Default skeleton loading
└── DefaultSectionedSkeletonView.swift # Skeleton for sections
```

**Features:**
- Configurable default views
- Customizable skeleton loading
- Consistent error handling
- Reusable UI across components

## 🔒 Private Implementation

### 🎨 UI Components

#### **Dynamic List**
Components for simple dynamic lists (without sections).

```
UI/Dynamic List/
├── DynamicListViewModel.swift         # ViewModel for simple lists
├── DynamicListViewState.swift         # View states for simple lists
├── DynamicListContent.swift           # Internal list content
├── DynamicListWrapper.swift           # Wrapper with NavigationStack
└── ListConfiguration.swift            # List configuration
```

**Features:**
- Simple lists with flat items
- Support for static and reactive data
- Loading, error, and success states
- Integrated pull-to-refresh
- Automatic navigation to details
- Advanced search system

#### **Sectioned Dynamic List**
Components for dynamic lists with sections and headers/footers.

```
UI/Sectioned Dynamic List/
├── SectionedDynamicListViewModel.swift     # ViewModel for sectioned lists
├── SectionedListViewState.swift            # View states for sectioned lists
├── SectionedDynamicListContent.swift       # Internal content for sectioned lists
├── SectionedDynamicListWrapper.swift       # Wrapper with NavigationStack
└── ListSection.swift                       # Data model for sections
```

**Features:**
- Lists organized in sections
- Headers and footers per section
- Support for arrays of arrays `[[Item]]`
- Advanced search system
- Intelligent filtering by section
- Same functionality as simple lists
- Section-specific skeleton loading

#### **Shared Components**
Components shared between both types of lists.

```
UI/Shared/
└── LoadingState.swift                 # Shared loading states
```

**Features:**
- Reusable loading states
- Shared enums and types
- Common logic between components

### 🧠 Domain Layer

#### **Search System**
Advanced search system with customizable strategies.

```
Domain/
├── Searchable.swift                   # Protocol for searchable items
├── SearchStrategy.swift               # Protocol for search strategies
└── Functional.swift                   # Functional utilities
```

**Features:**
- `Searchable` protocol for searchable items
- `SearchStrategy` protocol for customizable strategies
- Functional utilities for data processing
- Clear separation between data and search logic
- Extensible for custom strategies

### 🎭 Presentation Layer

#### **Localization**
Support for multiple languages.

```
Presentation/
├── DynamicListPresenter.swift         # Presenter for localization
├── en.lproj/                          # English resources
├── es-MX.lproj/                       # Mexican Spanish resources
├── fr.lproj/                          # French resources
└── pt.lproj/                          # Portuguese resources
```

**Features:**
- Complete package localization
- Support for 4 main languages
- Localized texts for errors and UI
- Easy extension to new languages

## 📚 Examples and Previews

SwiftUI examples and previews for development and testing.

```
Examples/
├── DynamicListPreviews.swift          # Previews for simple lists
├── DefaultViewsPreviews.swift         # Previews for default views
├── SearchEnabledExample.swift         # Search functionality example
├── ListConfigurationExample.swift     # List configuration example
├── ListStyleExample.swift             # List styling example
├── OptionalDetailContentExample.swift # Optional detail content example
└── CustomActionsExample.swift         # Custom actions example
```

**Features:**
- Comprehensive examples for all features
- SwiftUI previews for development
- Real-world usage patterns
- Testing scenarios

## 🧪 Tests

Unit and UI tests.

```
Tests/DynamicListTests/
├── DynamicListViewModelTests.swift    # Unit tests for simple list ViewModels
├── SectionedDynamicListViewModelTests.swift # Unit tests for sectioned list ViewModels
├── SearchViewModelTests.swift         # Tests for search functionality
├── SearchStrategyTests.swift          # Tests for search strategies
├── FunctionalTests.swift              # Functional integration tests
├── DynamicListPresenterTests.swift    # Tests for presentation layer
└── Helpers/
    └── TestItem.swift                 # Test model
```

**Features:**
- Comprehensive test coverage
- Tests organized by functionality
- Helper utilities for testing
- Integration and unit tests

## 🔗 Component Relationships

### Dynamic List Dependencies
```
DynamicListBuilder (Public)
├── DynamicList (Private)
├── DynamicListViewModel (Private)
├── DynamicListViewState (Private)
├── ListConfiguration (Private)
├── LoadingState (Private/Shared)
└── Default Views (Public)
```

### Sectioned Dynamic List Dependencies
```
SectionedDynamicListBuilder (Public)
├── SectionedDynamicList (Private)
├── SectionedDynamicListViewModel (Private)
├── SectionedListViewState (Private)
├── ListSection (Private)
├── LoadingState (Private/Shared)
└── Default Views (Public)
```

### Search System Dependencies
```
SearchConfiguration (Public)
├── Searchable (Private/Domain)
├── SearchStrategy (Private/Domain)
└── Search Strategies (Public)
```

### Shared Components
```
Shared/
└── LoadingState
    ├── DynamicList (uses)
    └── SectionedDynamicList (uses)

Default Views (Public)/
├── DynamicList (uses)
└── SectionedDynamicList (uses)

Domain/
├── Searchable
│   ├── DynamicList (uses)
│   └── SearchStrategy (uses)
└── SearchStrategy
    └── DynamicList (uses)
```

## 🎯 Organization Principles

### 1. **Separation of Responsibilities**
- **Public APIs**: Builders, configurations, and default views are publicly exposed
- **Private Implementation**: All internal logic is encapsulated
- **Domain Layer**: Business logic separated from UI
- **UI Components**: Specific components per list type

### 2. **Modularity**
- **Independent components**: Each list type has its own components
- **Clear dependencies**: Clear hierarchy of dependencies
- **Easy maintenance**: Isolated changes per component
- **Extensibility**: Easy to add new list types

### 3. **Reusability**
- **Shared components**: LoadingState and Default Views reusable
- **Reusable domain**: Search system independent of UI
- **Flexible configurations**: SearchConfiguration for different use cases

### 4. **Scalability**
- **Prepared architecture**: Structure ready for future extensions
- **Stable APIs**: Well-defined and stable public APIs
- **Complete testing**: Tests organized by functionality

## 🚀 Benefits of the New Structure

### For Developers
- **Clarity**: Clear separation between public APIs and private implementation
- **Maintenance**: Isolated changes per component and layer
- **Reusability**: Well-defined shared components
- **Testing**: Tests organized by functionality
- **Examples**: Comprehensive examples for all features

### For the Project
- **Scalability**: Easy to add new list types and features
- **Performance**: Only import what's necessary
- **Documentation**: Clear and documented structure
- **Quality**: Clear separation of responsibilities

## 📝 Naming Conventions

### Component Files
- `[ComponentName].swift` - Main component
- `[ComponentName]ViewModel.swift` - Component ViewModel
- `[ComponentName]ViewState.swift` - View states
- `[ComponentName]Builder.swift` - Builder pattern
- `[ComponentName]Content.swift` - Internal content
- `[ComponentName]Wrapper.swift` - Wrapper with navigation

### Domain Files
- `[Feature].swift` - Main protocols and types
- `[Feature]Strategy.swift` - Specific strategies
- `[Feature]Configuration.swift` - Configurations

### Test Files
- `[ComponentName]Tests.swift` - UI tests
- `[ComponentName]ViewModelTests.swift` - ViewModel tests
- `[Feature]Tests.swift` - Specific functionality tests

### Example Files
- `[Feature]Example.swift` - Feature-specific examples
- `[Component]Previews.swift` - SwiftUI previews

## 🔒 Access Control

### Public APIs
- `DynamicListBuilder<Item>` - Main builder for simple lists
- `SectionedDynamicListBuilder<Item>` - Builder for sectioned lists
- `SearchConfiguration<Item>` - Search configuration
- `ListStyleType` - List styling options
- `Searchable` - Protocol for searchable items
- `SearchStrategy` - Protocol for search strategies
- `PartialMatchStrategy` - Partial search implementation
- `ExactMatchStrategy` - Exact match search implementation
- `TokenizedMatchStrategy` - Token-based search implementation
- `DefaultRowView` - Default row view
- `DefaultDetailView` - Default detail view
- `DefaultErrorView` - Default error view
- `DefaultSkeletonView` - Default skeleton loading
- `DefaultSectionedSkeletonView` - Sectioned skeleton loading

### Private Implementation
- All UI components are marked as `internal`
- ViewModels and ViewStates are `internal`
- Domain components are `internal`
- ListConfiguration is `internal`

This structure provides a solid and scalable foundation for the `DynamicList` package, with clear separation of responsibilities and well-defined public APIs.