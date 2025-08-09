# Skeleton on Refresh Guide

This guide explains how to configure skeleton views to appear during refresh operations, not just during initial loading.

## Overview

By default, skeleton views are only shown when:
- The list is in a loading state (`isLoading = true`)
- **AND** the list is empty (`isEmpty = true`)

During refresh operations, the list maintains the previous data while loading new data, so `isEmpty = false` and the skeleton is not shown. Instead, the existing rows are redacted using `.placeholder` reason.

## Enabling Skeleton on Refresh

To show the custom skeleton view during refresh operations, use the `showSkeletonOnRefresh()` method:

### Simple List Example

```swift
DynamicListBuilder<User>()
    .publisher(apiService.fetchUsers())
    .skeletonRow(count: 5) {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity * 0.8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity * 0.6)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    .showSkeletonOnRefresh() // Enable skeleton during refresh
    .build()
```

### Sectioned List Example

```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .skeletonRow(
        sections: 2,
        itemsPerSection: 4,
        rowContent: {
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 14)
                        .frame(maxWidth: .infinity * 0.7)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 10)
                        .frame(maxWidth: .infinity * 0.5)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        },
        headerContent: {
            Text("Loading Section...")
                .font(.headline)
                .foregroundColor(.blue.opacity(0.6))
        }
    )
    .showSkeletonOnRefresh() // Enable skeleton during refresh
    .build()
```

## Configuration via ListConfiguration

You can also enable this behavior through `ListConfiguration`:

```swift
let config = ListConfiguration(
    style: .automatic,
    navigationBarHidden: false,
    title: "Users",
    showSkeletonOnRefresh: true
)

DynamicListBuilder<User>()
    .publisher(apiService.fetchUsers())
    .skeletonRow(count: 5) {
        Text("Loading...")
    }
    .listConfiguration(config)
    .build()
```

Or using the convenience method:

```swift
DynamicListBuilder<User>()
    .publisher(apiService.fetchUsers())
    .skeletonRow(count: 5) {
        Text("Loading...")
    }
    .listConfiguration(.showSkeletonOnRefresh)
    .build()
```

## When to Use

### ✅ Good Use Cases

- **Long loading times**: When refresh operations take several seconds
- **Complex skeleton designs**: When you have carefully crafted skeleton views that match your content
- **Consistent UX**: When you want the same loading experience for initial load and refresh
- **Heavy data**: When loading large amounts of data that benefit from visual feedback

### ❌ When Not to Use

- **Fast APIs**: When refresh completes in under 1 second
- **Simple content**: When default redaction is sufficient
- **Performance concerns**: When skeleton rendering might impact scroll performance
- **Minimal designs**: When you prefer subtle loading indicators

## Default Behavior Comparison

| Scenario | Default Behavior | With `showSkeletonOnRefresh()` |
|----------|------------------|-------------------------------|
| Initial Load (empty list) | Shows skeleton | Shows skeleton |
| Refresh (with existing data) | Shows redacted rows | Shows custom skeleton |
| Error state (empty list) | Shows error view | Shows error view |
| Error state (with existing data) | Shows redacted rows + error | Shows redacted rows + error |

## Implementation Details

The `showSkeletonOnRefresh()` method modifies the `shouldShowLoading` logic from:

```swift
// Default behavior
var shouldShowLoading: Bool { isLoading && isEmpty }
```

To:

```swift
// With showSkeletonOnRefresh enabled
func shouldShowLoading(showSkeletonOnRefresh: Bool) -> Bool {
    isLoading && (isEmpty || showSkeletonOnRefresh)
}
```

This means the skeleton will be shown whenever the list is loading, regardless of whether it has existing data.

## Best Practices

1. **Test both scenarios**: Verify skeleton works for both initial load and refresh
2. **Consider timing**: Ensure skeleton duration matches your API response times
3. **Match your design**: Create skeleton views that closely resemble your actual content
4. **Performance**: Monitor scroll performance when skeleton is shown during refresh
5. **Accessibility**: Ensure skeleton views don't interfere with VoiceOver or other accessibility features

## Troubleshooting

### Skeleton not showing during refresh
- Verify you called `.showSkeletonOnRefresh()`
- Check that you have a custom skeleton configured (`.skeletonRow()` or `.skeletonContent()`)
- Ensure your data provider actually triggers a loading state

### Performance issues
- Simplify skeleton views if scroll performance is affected
- Consider using default redaction instead for complex lists
- Test on older devices to ensure smooth experience

### Unexpected behavior
- Remember that this affects **all** loading states, not just refresh
- The skeleton will show even when transitioning between different data sources
- Error states with existing data will still show redacted content, not skeleton
