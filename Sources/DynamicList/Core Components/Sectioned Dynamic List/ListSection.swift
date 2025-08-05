//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents a section in a list with optional header and footer
public struct ListSection<Item: Identifiable & Hashable>: Identifiable, Hashable {
    public let id = UUID()
    public let title: String?
    public let items: [Item]
    public let footer: String?

    public init(title: String? = nil, items: [Item], footer: String? = nil) {
        self.title = title
        self.items = items
        self.footer = footer
    }

    public static func == (lhs: ListSection<Item>, rhs: ListSection<Item>) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
