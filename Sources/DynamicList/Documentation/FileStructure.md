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
│       │   │   ├── Default Views/     # Default views
│       │   │   └── Shared/            # Shared components
│       │   ├── Domain/                # Domain logic
│       │   │   └── Strategies/        # Search strategies
│       │   └── Presentation/          # Presentation components
│       ├── PreviewSupport/            # SwiftUI Previews support
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

## 🔒 Private Implementation

### 🎨 UI Components

#### **Dynamic List**
Components for simple dynamic lists (without sections).

```
UI/Dynamic List/
├── DynamicListViewModel.swift     # ViewModel for simple lists
├── DynamicListViewState.swift     # View states for simple lists
├── DynamicListContent.swift       # Internal list content
├── DynamicListWrapper.swift       # Wrapper with NavigationStack
└── SearchConfiguration.swift      # Search configuration
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

#### **Default Views**
Default views and reusable UI components.

```
UI/Default Views/
├── DefaultRowView.swift           # Default row view
├── DefaultDetailView.swift        # Default detail view
├── DefaultErrorView.swift         # Default error view
├── DefaultSkeletonView.swift      # Default skeleton loading
└── DefaultSectionedSkeletonView.swift # Skeleton for sections
```

**Features:**
- Configurable default views
- Customizable skeleton loading
- Consistent error handling
- Reusable UI across components

#### **Shared Components**
Components shared between both types of lists.

```
UI/Shared/
└── LoadingState.swift             # Shared loading states
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
├── Searchable.swift               # Protocol for searchable items
├── SearchStrategy.swift           # Protocol for search strategies
└── Strategies/                    # Strategy implementations
    ├── PartialMatchStrategy.swift # Partial search (default)
    ├── ExactMatchStrategy.swift   # Exact match
    └── TokenizedMatchStrategy.swift # Token-based search
```

**Features:**
- `Searchable` protocol for searchable items
- `SearchStrategy` protocol for customizable strategies
- Predefined strategies: partial, exact, and tokenized
- Clear separation between data and search logic
- Extensible for custom strategies

### 🎭 Presentation Layer

#### **Localization**
Support for multiple languages.

```
Presentation/
├── DynamicListPresenter.swift     # Presenter for localization
├── en.lproj/                      # English resources
├── es-MX.lproj/                   # Mexican Spanish resources
├── fr.lproj/                      # French resources
└── pt.lproj/                      # Portuguese resources
```

**Features:**
- Complete package localization
- Support for 4 main languages
- Localized texts for errors and UI
- Easy extension to new languages

## 📚 Documentation

Complete project documentation.

```
Documentation/
├── README.md                      # Main documentation
├── DeveloperGuide.md              # Developer guide
└── FileStructure.md               # This documentation
```

## 👀 PreviewSupport

Support for SwiftUI Previews and examples.

```
PreviewSupport/
├── DynamicListPreviews.swift      # Previews for simple lists
└── DefaultViewsPreviews.swift     # Previews for default views
```

## 🧪 Tests

Unit and UI tests.

```
Tests/DynamicListTests/
├── DynamicListTests.swift         # UI tests for simple lists
├── DynamicListViewModelTests.swift # Unit tests for ViewModels
├── SearchStrategyTests.swift      # Tests for search strategies
└── Helpers/
    └── TestItem.swift             # Test model
```

## 🔗 Component Relationships

### Dynamic List Dependencies
```
DynamicListBuilder (Public)
├── DynamicList (Private)
├── DynamicListViewModel (Private)
├── DynamicListViewState (Private)
├── SearchConfiguration (Private)
├── LoadingState (Private/Shared)
└── Default Views (Private)
```

### Sectioned Dynamic List Dependencies
```
SectionedDynamicListBuilder (Public)
├── SectionedDynamicList (Private)
├── SectionedDynamicListViewModel (Private)
├── SectionedListViewState (Private)
├── ListSection (Private)
├── SearchConfiguration (Private)
├── LoadingState (Private/Shared)
└── Default Views (Private)
```

### Search System Dependencies
```
SearchConfiguration (Private)
├── Searchable (Private/Domain)
├── SearchStrategy (Private/Domain)
└── Strategies (Private/Domain)
```

### Shared Components
```
Shared/
└── LoadingState
    ├── DynamicList (uses)
    └── SectionedDynamicList (uses)

Default Views/
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
- **Public APIs**: Only builders are publicly exposed
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

## 🔒 Access Control

### Public APIs
- `DynamicListBuilder<Item>` - Main builder for simple lists
- `SectionedDynamicListBuilder<Item>` - Builder for sectioned lists
- `SearchConfiguration<Item>` - Search configuration
- `Searchable` - Protocol for searchable items
- `SearchStrategy` - Protocol for search strategies

### Private Implementation
- All UI components are marked as `internal`
- ViewModels and ViewStates are `internal`
- Domain components are `internal`
- Search strategies are `internal`

This structure provides a solid and scalable foundation for the `DynamicList` package, with clear separation of responsibilities and well-defined public APIs.