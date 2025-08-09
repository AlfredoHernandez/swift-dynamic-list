# Sectioned Skeleton Guide

The `SectionedDynamicListBuilder` provides powerful skeleton loading capabilities with support for custom headers and footers.

## Basic Skeleton Row

The simplest way to create a skeleton is using just a row view:

```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .skeletonRow(sections: 3, itemsPerSection: 4) {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 18)
                    .frame(maxWidth: .infinity * 0.8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity * 0.6)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
    .build()
```

## Skeleton with Custom Header

Add a custom header skeleton to match your section headers:

```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .skeletonRow(
        sections: 2,
        itemsPerSection: 5,
        rowContent: {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                Text("Loading product...")
                    .foregroundColor(.gray.opacity(0.7))
                Spacer()
            }
        },
        headerContent: {
            Text("Category Loading...")
                .font(.headline)
                .foregroundColor(.blue.opacity(0.7))
        }
    )
    .build()
```

## Complete Skeleton with Header and Footer

For maximum customization, provide both header and footer skeletons:

```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .skeletonRow(
        sections: 2,
        itemsPerSection: 4,
        rowContent: {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 18)
                        .frame(maxWidth: .infinity * 0.8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 14)
                        .frame(maxWidth: .infinity * 0.6)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        },
        headerContent: {
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.4))
                    .frame(height: 25)
                    .frame(maxWidth: .infinity * 0.6)
                Spacer()
            }
            .padding(.vertical, 4)
        },
        footerContent: {
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.purple.opacity(0.3))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity * 0.4)
                Spacer()
            }
            .padding(.vertical, 2)
        }
    )
    .build()
```

### Footer Only Example
```swift
SectionedDynamicListBuilder<User>()
    .publisher(apiService.fetchUsersByCategory())
    .skeletonRow(
        sections: 2,
        itemsPerSection: 4,
        rowContent: {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .frame(maxWidth: .infinity * 0.8)
                }
                Spacer()
            }
        },
        footerContent: {
            Text("Loading more...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    )
    .build()
```

## Method Overloads

The `SectionedDynamicListBuilder` provides four overloads of the `skeletonRow` method for different use cases:

### 1. Basic Row Only
```swift
func skeletonRow(
    sections: Int = 3,
    itemsPerSection: Int = 4,
    @ViewBuilder _ content: @escaping () -> some View
) -> Self
```

### 2. Row with Custom Header
```swift
func skeletonRow(
    sections: Int = 3,
    itemsPerSection: Int = 4,
    @ViewBuilder rowContent: @escaping () -> some View,
    @ViewBuilder headerContent: @escaping () -> some View
) -> Self
```

### 3. Row with Custom Header and Footer
```swift
func skeletonRow(
    sections: Int = 3,
    itemsPerSection: Int = 4,
    @ViewBuilder rowContent: @escaping () -> some View,
    @ViewBuilder headerContent: @escaping () -> some View,
    @ViewBuilder footerContent: @escaping () -> some View
) -> Self
```

### 4. Row with Custom Footer Only
```swift
func skeletonRow(
    sections: Int = 3,
    itemsPerSection: Int = 4,
    @ViewBuilder rowContent: @escaping () -> some View,
    @ViewBuilder footerContent: @escaping () -> some View
) -> Self
```

The compiler will automatically choose the appropriate overload based on the parameters you provide, making the API simple and intuitive to use.

## Default Behavior

- **Default Header**: When no header is provided, no header is shown (EmptyView)
- **Default Footer**: When no footer is provided, no footer is shown (EmptyView)
- **Automatic Styling**: The skeleton inherits the list style configuration
- **Redaction**: All skeleton content is automatically redacted with `.placeholder` reason

## Best Practices

1. **Match Your Design**: Create skeleton views that closely match your actual content structure
2. **Use Opacity**: Use gray colors with opacity (0.2-0.4) for a subtle skeleton effect
3. **Consistent Spacing**: Maintain the same padding and spacing as your real content
4. **Appropriate Counts**: Use realistic section and item counts that match your expected data
5. **Performance**: Keep skeleton views simple to ensure smooth rendering during loading

## Integration with List Styles

The skeleton automatically adapts to your list style:

```swift
SectionedDynamicListBuilder<Product>()
    .listStyle(.grouped) // Skeleton will use grouped style
    .skeletonRow(/* ... */)
    .build()
```

## Notes

- The skeleton is only shown during loading states when no data is available
- Works correctly with both `build()` and `buildWithoutNavigation()` methods
- If both `skeletonContent` and `skeletonRow` are used, `skeletonRow` takes precedence
- All skeleton content is automatically redacted for the loading effect
