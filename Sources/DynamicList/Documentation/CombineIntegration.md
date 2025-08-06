# Combine Integration in DynamicList

## General Description

`DynamicList` now supports complete integration with Combine, allowing you to obtain data from external services reactively. This includes support for:

- REST APIs
- Local databases (Core Data, SQLite)
- Real-time services (Firebase, Firestore)
- Local JSON files
- Any source that produces an `AnyPublisher<[Item], Error>`

## New Features

### 1. Loading States
- **`isLoading`**: Indicates if data is being loaded
- **`error`**: Contains any error that occurred
- **Visual states**: Loading spinner and automatic error screens

### 2. Reactivity
- Automatic updates when data changes
- Support for real-time data
- Automatic subscription cancellation

### 3. Flexibility
- Compatible with static and dynamic data
- Runtime data source changes
- Integrated error handling
- **Functional refresh**: Real data reload with `refresh()`

## Basic Usage

### With Static Data (No Changes)
```swift
let viewModel = DynamicListViewModel<Task>(
    items: [
        Task(title: "Example", description: "Static data")
    ]
)
```

### With Data Provider (New API)
```swift
let viewModel = DynamicListViewModel<Task> {
    dataService.loadTasks()
}
```

## Implementation Examples

### 1. REST API with URLSession
```swift
func loadUsers() -> AnyPublisher<[User], Error> {
    let url = URL(string: "https://api.example.com/users")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

// Usage
let viewModel = DynamicListViewModel<User> {
    loadUsers()
}
```

### 2. Local JSON
```swift
func loadTasksFromBundle() -> AnyPublisher<[Task], Error> {
    guard let url = Bundle.main.url(forResource: "tasks", withExtension: "json") else {
        return Fail(error: ServiceError.fileNotFound)
            .eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [Task].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

// Usage
let viewModel = DynamicListViewModel<Task> {
    loadTasksFromBundle()
}
```

### 3. Reactive Local Database
```swift
class DatabaseService {
    private let subject = PassthroughSubject<[Task], Error>()
    
    var tasksPublisher: AnyPublisher<[Task], Error> {
        subject.eraseToAnyPublisher()
    }
    
    func addTask(_ task: Task) {
        // Save to database
        // Emit new list
        subject.send(updatedTasks)
    }
}

// Usage
let viewModel = DynamicListViewModel<Task> {
    databaseService.tasksPublisher
}
```

### 4. Simulated Firebase/Firestore
```swift
func listenToTasks() -> AnyPublisher<[Task], Error> {
    let subject = PassthroughSubject<[Task], Error>()
    
    // Configure Firestore listener
    // db.collection("tasks").addSnapshotListener { snapshot, error in
    //     if let error = error {
    //         subject.send(completion: .failure(error))
    //         return
    //     }
    //     
    //     let tasks = snapshot?.documents.compactMap { ... }
    //     subject.send(tasks ?? [])
    // }
    
    return subject.eraseToAnyPublisher()
}

// Usage
let viewModel = DynamicListViewModel<Task> {
    listenToTasks()
}
```

## ViewModel API

### Initializers
```swift
// With static data
init(items: [Item] = [])

// With data provider (new API)
init(dataProvider: @escaping () -> AnyPublisher<[Item], Error>, initialItems: [Item] = [])
```

### Public Methods
```swift
// Change data source dynamically
func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>)

// Reload data (now functional)
func refresh()
```

### Observable Properties
```swift
var items: [Item]           // Items to display
var isLoading: Bool         // Loading state
var error: Error?           // Error if occurred
```

## Automatic Visual States

The `DynamicList` view automatically handles:

1. **Initial Loading**: Shows `ProgressView` if `isLoading` is `true` and there are no items
2. **Error State**: Shows error screen if there's an error and no items
3. **List with Data**: Shows normal list when there are items
4. **Pull to Refresh**: Complete support for refreshing with real data

## Error Handling

```swift
enum ServiceError: Error, LocalizedError {
    case networkError
    case invalidURL
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Connection error"
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Error processing data"
        }
    }
}
```

## Advanced Use Cases

### Dynamic Source Change
```swift
// Initialize with one source
let viewModel = DynamicListViewModel<Task> {
    localService.loadTasks()
}

// Change to another source later
viewModel.loadItems {
    firebaseService.loadTasks()
}
```

### Dynamic Filters with Parameters
```swift
// Load all tasks
viewModel.loadItems {
    service.loadAllTasks()
}

// Change to completed only
viewModel.loadItems {
    service.loadCompletedTasks()
}

// With dynamic parameters
let currentFilter = TaskFilter.completed
viewModel.loadItems {
    service.loadTasks(filter: currentFilter)
}
```

### Real-time Data
```swift
// The data provider is called every time refresh is needed
let viewModel = DynamicListViewModel<Task> {
    realtimeService.tasksStream
}

// UI updates automatically
// And refresh() gets fresh data
```

### Functional Refresh
```swift
// Now refresh() really reloads data
viewModel.refresh() // Calls the data provider and gets fresh data
```

## Performance Considerations

1. **Threading**: All publishers run on the main thread automatically
2. **Cancellation**: Previous subscriptions are cancelled when changing source or refreshing
3. **Memory**: The ViewModel maintains weak references to avoid retention cycles
4. **Updates**: UI is only updated when data actually changes
5. **Fresh Data**: Each `refresh()` gets updated data from the data provider

## Migration from Previous Version

Existing code continues to work without changes:

```swift
// This still works the same
let viewModel = DynamicListViewModel<Item>(items: staticItems)
```

To take advantage of new features, change from direct publisher to data provider:

```swift
// Before
let viewModel = DynamicListViewModel<Item>(
    publisher: yourDataService.loadItems()
)

// Now
let viewModel = DynamicListViewModel<Item> {
    yourDataService.loadItems()
}
```

## Advantages of the New API

- ✅ **Functional refresh**: `refresh()` now really reloads data
- ✅ **More flexible**: You can capture parameters in the closure
- ✅ **Fresh data**: Each refresh gets updated data
- ✅ **Better testing**: Easier to mock a function than a publisher
- ✅ **Dynamic parameters**: The data provider can use context variables