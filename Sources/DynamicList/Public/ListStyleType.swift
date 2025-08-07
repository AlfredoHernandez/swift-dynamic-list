//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Enum representing available list styles
public enum ListStyleType {
    case automatic
    case plain
    case inset
    #if os(iOS)
    case grouped
    case insetGrouped
    #endif
}
