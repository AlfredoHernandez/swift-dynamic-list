//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Defines the visual style and behavior of list presentations in DynamicList components.
///
/// `ListStyleType` provides a unified interface for configuring list appearance across different
/// platforms while maintaining platform-specific optimizations and design patterns.
///
/// ## Usage
/// ```swift
/// DynamicListBuilder(items: items)
///     .listStyle(.insetGrouped)
///     .build()
/// ```
///
/// ## Performance Considerations
/// - `.automatic` adapts to the current platform and context for optimal performance
/// - `.plain` provides the most lightweight rendering
/// - Grouped styles may have additional memory overhead due to section management
public enum ListStyleType {
    /// Automatically selects the most appropriate list style for the current platform and context.
    ///
    /// This style adapts based on:
    /// - Current platform (iOS, macOS, watchOS, tvOS)
    /// - Available screen space
    /// - System accessibility settings
    /// - User interface idiom (phone, pad, mac)
    ///
    /// **Recommended** for most use cases as it provides optimal user experience
    /// across all supported platforms.
    case automatic

    /// A simple list style with minimal visual decoration.
    ///
    /// Characteristics:
    /// - No background or border styling
    /// - Minimal spacing between items
    /// - Optimal for content-focused presentations
    /// - Best performance for large datasets
    ///
    /// **Use when**: Content should be the primary focus, or when maximum
    /// performance is required for large lists.
    case plain

    /// A list style with subtle inset margins and background styling.
    ///
    /// Characteristics:
    /// - Inset from the edges of the container
    /// - Subtle background styling
    /// - Balanced visual hierarchy
    /// - Good for mixed content types
    ///
    /// **Use when**: You need visual separation from the container while
    /// maintaining a clean, modern appearance.
    case inset

    #if os(iOS)
    /// A list style that groups items into visually distinct sections with headers and footers.
    ///
    /// **iOS Only** - This style is optimized for iOS design patterns and user expectations.
    ///
    /// Characteristics:
    /// - Clear section separation
    /// - Traditional iOS grouped table view appearance
    /// - Optimal for settings screens and form-like interfaces
    /// - Supports section headers and footers
    ///
    /// **Use when**: Presenting hierarchical data or form-like interfaces
    /// where clear section boundaries improve usability.
    case grouped

    /// Combines the visual benefits of both inset and grouped styles.
    ///
    /// **iOS Only** - This style provides the most modern iOS appearance.
    ///
    /// Characteristics:
    /// - Inset margins with grouped section styling
    /// - Rounded corners on section groups
    /// - Modern iOS design language
    /// - Enhanced visual hierarchy
    /// - Optimal spacing for touch interactions
    ///
    /// **Use when**: Building modern iOS interfaces that need clear content
    /// organization with contemporary visual styling.
    case insetGrouped
    #endif
}
