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
    Product(name: "iPhone 15", price: 999.0, category: "Electronics"),
    Product(name: "MacBook Pro", price: 1999.0, category: "Electronics"),
    Product(name: "AirPods Pro", price: 249.0, category: "Audio"),
    Product(name: "iPad Air", price: 599.0, category: "Tablets"),
    Product(name: "Apple Watch", price: 399.0, category: "Wearables"),
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
