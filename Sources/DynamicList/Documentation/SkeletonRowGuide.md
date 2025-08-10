# Skeleton Row Guide

## Overview

The `skeletonRow` method provides a simplified way to create skeleton loading states by defining only a single row view. The library automatically generates a full skeleton list by repeating your row design.

## Benefits

- **Simplified API**: Define only one row instead of a complete list
- **Automatic Generation**: The library handles list creation and repetition
- **Consistent Styling**: Automatically applies your list style configuration
- **Flexible Configuration**: Customize count, sections, and items per section

## Basic Usage

### Simple Lists

```swift
DynamicListBuilder<User>()
    .publisher(apiService.fetchUsers())
    .skeletonRow(count: 8) {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 18)
                    .frame(maxWidth: .infinity * 0.7)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity * 0.5)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
    .rowContent { user in
        // Your actual row content
        UserRowView(user: user)
    }
    .build()
```

### Sectioned Lists

```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .skeletonRow(sections: 3, itemsPerSection: 5) {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity * 0.8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity * 0.4)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    .rowContent { product in
        // Your actual row content
        ProductRowView(product: product)
    }
    .build()
```

## Parameters

### Simple Lists

- `count`: Number of skeleton rows to display (default: 10)
- `content`: ViewBuilder closure that creates a single skeleton row

### Sectioned Lists

- `sections`: Number of sections to display (default: 3)
- `itemsPerSection`: Number of items per section (default: 4)
- `content`: ViewBuilder closure that creates a single skeleton row

## Design Tips

1. **Match Your Content**: Design skeleton rows that closely match your actual content structure
2. **Use Appropriate Opacity**: Use `Color.gray.opacity(0.3)` for primary elements and `opacity(0.2)` for secondary
3. **Vary Widths**: Use different `maxWidth` multipliers to create realistic text length variation
4. **Consider Spacing**: Match the padding and spacing of your actual rows

## Migration from skeletonContent

### Before (using skeletonContent)
```swift
.skeletonContent {
    List(0..<10, id: \.self) { _ in
        HStack {
            Circle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)).frame(height: 16)
                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2)).frame(height: 12)
            }
            Spacer()
        }
    }
    .redacted(reason: .placeholder)
}
```

### After (using skeletonRow)
```swift
.skeletonRow(count: 10) {
    HStack {
        Circle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40)
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.3)).frame(height: 16)
            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2)).frame(height: 12)
        }
        Spacer()
    }
}
```

## Notes

- The `skeletonRow` method automatically applies `.redacted(reason: .placeholder)` and proper list styling
- If both `skeletonContent` and `skeletonRow` are used, `skeletonRow` takes precedence
- The skeleton view inherits the list style configuration from your builder
- Works correctly with both `build()` and `buildWithoutNavigation()` methods
