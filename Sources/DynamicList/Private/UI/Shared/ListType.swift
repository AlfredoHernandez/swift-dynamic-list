//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents the type of dynamic list
enum ListType<Item: Identifiable & Hashable> {
    case simple(items: [Item])
    case sectioned(sections: [ListSection<Item>])

    var isEmpty: Bool {
        switch self {
        case let .simple(items):
            items.isEmpty
        case let .sectioned(sections):
            sections.isEmpty || sections.allSatisfy(\.items.isEmpty)
        }
    }

    var allItems: [Item] {
        switch self {
        case let .simple(items):
            items
        case let .sectioned(sections):
            sections.flatMap(\.items)
        }
    }
}
