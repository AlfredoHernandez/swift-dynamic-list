//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Shared Example Models & Data

/// Color options for fruit examples in previews
enum FruitColor: CaseIterable {
    case red, yellow, green, orange, purple, blue, black, brown, white
}

/// Fruit model used in previews
struct Fruit: Identifiable, Hashable {
    var id: UUID = .init()
    let name: String
    let symbol: String
    let color: FruitColor
}

/// User model for examples
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let role: String
    let isActive: Bool
}

/// Product model for examples
struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let category: String
}

/// Task model for examples
struct Task: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let priority: String
    let isCompleted: Bool
}

/// Searchable user model
struct SearchableUser: Identifiable, Hashable, Searchable {
    let id = UUID()
    let name: String
    let email: String
    let role: String

    var searchKeys: [String] {
        [name, email, role]
    }
}

/// Error types
enum LoadError: Error, LocalizedError {
    case networkError, unauthorized, serverError

    var errorDescription: String? {
        switch self {
        case .networkError: "No internet connection"
        case .unauthorized: "You don't have permission to access"
        case .serverError: "Server error"
        }
    }
}

// MARK: - Sample Data

let fruits = [
    Fruit(name: "Watermelon", symbol: "🍉", color: .red),
    Fruit(name: "Pear", symbol: "🍐", color: .green),
    Fruit(name: "Apple", symbol: "🍎", color: .red),
    Fruit(name: "Orange", symbol: "🍊", color: .orange),
    Fruit(name: "Banana", symbol: "🍌", color: .yellow),
    Fruit(name: "Strawberry", symbol: "🍓", color: .red),
    Fruit(name: "Blueberry", symbol: "🫐", color: .blue),
    Fruit(name: "Grape", symbol: "🍇", color: .purple),
    Fruit(name: "Pineapple", symbol: "🍍", color: .yellow),
    Fruit(name: "Lemon", symbol: "🍋", color: .yellow),
]

let users = [
    User(name: "Alice Johnson", email: "alice@example.com", role: "Admin", isActive: true),
    User(name: "Bob Smith", email: "bob@example.com", role: "User", isActive: false),
    User(name: "Carol Davis", email: "carol@example.com", role: "Manager", isActive: true),
    User(name: "David Wilson", email: "david@example.com", role: "User", isActive: true),
    User(name: "Eva Brown", email: "eva@example.com", role: "Admin", isActive: false),
]

let products = [
    // Electronics
    Product(name: "iPhone 15 Pro", price: 1199.0, category: "Electronics"),
    Product(name: "iPhone 15", price: 999.0, category: "Electronics"),
    Product(name: "MacBook Pro 16\"", price: 2499.0, category: "Electronics"),
    Product(name: "MacBook Pro 14\"", price: 1999.0, category: "Electronics"),
    Product(name: "MacBook Air 15\"", price: 1299.0, category: "Electronics"),
    Product(name: "MacBook Air 13\"", price: 1099.0, category: "Electronics"),
    Product(name: "iMac 24\"", price: 1499.0, category: "Electronics"),
    Product(name: "Mac Studio", price: 1999.0, category: "Electronics"),
    Product(name: "Mac Pro", price: 5999.0, category: "Electronics"),
    Product(name: "Apple TV 4K", price: 179.0, category: "Electronics"),

    // Audio
    Product(name: "AirPods Pro 2", price: 249.0, category: "Audio"),
    Product(name: "AirPods Max", price: 549.0, category: "Audio"),
    Product(name: "AirPods 3", price: 179.0, category: "Audio"),
    Product(name: "AirPods 2", price: 129.0, category: "Audio"),
    Product(name: "HomePod mini", price: 99.0, category: "Audio"),
    Product(name: "HomePod", price: 299.0, category: "Audio"),
    Product(name: "Beats Studio Pro", price: 349.0, category: "Audio"),
    Product(name: "Beats Solo3", price: 199.0, category: "Audio"),

    // Tablets
    Product(name: "iPad Pro 12.9\"", price: 1099.0, category: "Tablets"),
    Product(name: "iPad Pro 11\"", price: 799.0, category: "Tablets"),
    Product(name: "iPad Air", price: 599.0, category: "Tablets"),
    Product(name: "iPad 10th gen", price: 449.0, category: "Tablets"),
    Product(name: "iPad 9th gen", price: 329.0, category: "Tablets"),
    Product(name: "iPad mini", price: 499.0, category: "Tablets"),

    // Wearables
    Product(name: "Apple Watch Series 9", price: 399.0, category: "Wearables"),
    Product(name: "Apple Watch Ultra 2", price: 799.0, category: "Wearables"),
    Product(name: "Apple Watch SE", price: 249.0, category: "Wearables"),
    Product(name: "Apple Watch Series 8", price: 399.0, category: "Wearables"),

    // Accessories
    Product(name: "Magic Keyboard", price: 99.0, category: "Accessories"),
    Product(name: "Magic Mouse", price: 79.0, category: "Accessories"),
    Product(name: "Magic Trackpad", price: 129.0, category: "Accessories"),
    Product(name: "Apple Pencil 2", price: 129.0, category: "Accessories"),
    Product(name: "Apple Pencil 1", price: 99.0, category: "Accessories"),
    Product(name: "Smart Keyboard Folio", price: 179.0, category: "Accessories"),
    Product(name: "Magic Keyboard Folio", price: 249.0, category: "Accessories"),
    Product(name: "iPhone 15 Pro Case", price: 49.0, category: "Accessories"),
    Product(name: "AirTag", price: 29.0, category: "Accessories"),
    Product(name: "AirTag 4-Pack", price: 99.0, category: "Accessories"),

    // Software & Services
    Product(name: "iCloud+ 50GB", price: 0.99, category: "Software & Services"),
    Product(name: "iCloud+ 200GB", price: 2.99, category: "Software & Services"),
    Product(name: "iCloud+ 2TB", price: 9.99, category: "Software & Services"),
    Product(name: "Apple One Individual", price: 16.95, category: "Software & Services"),
    Product(name: "Apple One Family", price: 22.95, category: "Software & Services"),
    Product(name: "Apple One Premier", price: 32.95, category: "Software & Services"),
]

let tasks = [
    Task(title: "Buy groceries", priority: "High", isCompleted: false),
    Task(title: "Call dentist", priority: "Medium", isCompleted: true),
    Task(title: "Read documentation", priority: "Low", isCompleted: false),
    Task(title: "Exercise", priority: "High", isCompleted: false),
    Task(title: "Plan vacation", priority: "Medium", isCompleted: true),
]

let searchableUsers = [
    SearchableUser(name: "Ana García", email: "ana@example.com", role: "Admin"),
    SearchableUser(name: "Bob Smith", email: "bob@example.com", role: "User"),
    SearchableUser(name: "Carlos López", email: "carlos@example.com", role: "Manager"),
    SearchableUser(name: "Diana Chen", email: "diana@example.com", role: "User"),
]
