# Custom Error Views in DynamicList

## General Description

`DynamicList` allows you to completely customize the view that is displayed when an error occurs while loading data. You can use the default error view or create your own custom view.

## Basic Usage

### Default Error View

If you don't specify a custom error view, `DynamicList` will automatically use the default view:

```swift
let viewModel = DynamicListViewModel<Task>(
    publisher: dataService.loadTasks()
)

DynamicList(
    viewModel: viewModel,
    rowContent: { task in
        Text(task.title)
    },
    detailContent: { task in
        Text("Detail: \(task.title)")
    }
    // No errorContent specified = uses default view
)
```

The default view includes:
- ⚠️ Orange warning icon
- Title "Error loading data"
- Error description
- Centered and responsive design

### Custom Error View

To use a custom error view, provide the `errorContent` parameter:

```swift
DynamicList(
    viewModel: viewModel,
    rowContent: { task in
        Text(task.title)
    },
    detailContent: { task in
        Text("Detail: \(task.title)")
    },
    errorContent: { error in
        // Your custom view here
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text("Error: \(error.localizedDescription)")
        }
    }
)
```

## Error View Examples

### 1. Error View with Retry Button

```swift
errorContent: { error in
    VStack(spacing: 20) {
        Image(systemName: "wifi.slash")
            .font(.system(size: 60))
            .foregroundColor(.red)
        
        Text("No Connection")
            .font(.largeTitle)
            .fontWeight(.bold)
        
        Text(error.localizedDescription)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
        
        Button("Retry") {
            viewModel.refresh()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    .padding()
}
```

### 2. Minimalist Error View

```swift
errorContent: { error in
    HStack {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.red)
        Text(error.localizedDescription)
            .foregroundColor(.secondary)
    }
    .padding()
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

### 3. Error View with Different States

```swift
errorContent: { error in
    VStack(spacing: 16) {
        let (icon, color, title) = errorInfo(for: error)
        
        Image(systemName: icon)
            .font(.system(size: 48))
            .foregroundColor(color)
        
        Text(title)
            .font(.headline)
        
        Text(error.localizedDescription)
            .font(.caption)
            .foregroundColor(.secondary)
        
        Button("Retry") {
            viewModel.refresh()
        }
        .buttonStyle(.bordered)
    }
    .padding()
}

func errorInfo(for error: Error) -> (icon: String, color: Color, title: String) {
    switch error {
    case is URLError:
        return ("wifi.slash", .orange, "No Connection")
    case let customError as CustomError where customError.isAuthError:
        return ("person.slash", .red, "Not Authorized")
    default:
        return ("exclamationmark.triangle", .yellow, "General Error")
    }
}
```

### 4. Error View with Animations

```swift
errorContent: { error in
    VStack(spacing: 20) {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 60))
            .foregroundColor(.orange)
            .scaleEffect(animating ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(), value: animating)
            .onAppear { animating = true }
        
        Text("Oops! Something went wrong")
            .font(.title2)
            .fontWeight(.semibold)
        
        Text(error.localizedDescription)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }
    .padding()
}
```

## Best Practices

### 1. Design Consistency
Keep the style consistent with your application:

```swift
errorContent: { error in
    ErrorCard(error: error) // Your reusable component
}
```

### 2. Accessibility
Make sure your error view is accessible:

```swift
errorContent: { error in
    VStack {
        Image(systemName: "exclamationmark.triangle")
            .accessibilityLabel("Error")
        Text(error.localizedDescription)
            .accessibilityRole(.text)
    }
    .accessibilityElement(children: .combine)
}
```

### 3. Specific Error Handling
Customize the view based on error type:

```swift
errorContent: { error in
    switch error {
    case let networkError as URLError:
        NetworkErrorView(error: networkError)
    case let authError as AuthenticationError:
        AuthErrorView(error: authError)
    default:
        GenericErrorView(error: error)
    }
}
```

### 4. Loading States with Previous Data
When previous data is available, consider showing an overlay instead of replacing the entire view:

```swift
// ViewState handles this automatically
// If there are existing items, shouldShowError will be false
// and you can show an overlay or error banner
```

## Integration with ViewState

Custom error views integrate perfectly with the state system:

```swift
// The error view is only shown when:
viewModel.viewState.shouldShowError == true

// This happens when:
// - loadingState == .error(let error)
// - items.isEmpty == true
```

## Complete Examples

### Error View with Multiple Actions

```swift
struct MultiActionErrorView: View {
    let error: Error
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 72))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Error Loading")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                
                Button("Retry") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Usage:
errorContent: { error in
    MultiActionErrorView(
        error: error,
        onRetry: { viewModel.refresh() },
        onCancel: { /* cancel action */ }
    )
}
```

## Compatibility

- ✅ **Backward compatibility**: Existing code continues to work without changes
- ✅ **Type safe**: The compiler verifies that types are correct
- ✅ **Flexible**: You can use any SwiftUI view
- ✅ **Reusable**: Error views can be independent components