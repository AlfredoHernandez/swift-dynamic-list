//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

// MARK: - Preview Models

/// Color options for fruit examples in previews
enum FruitColor: CaseIterable {
    case red
    case yellow
    case green
    case orange
    case purple
}

/// Fruit model used in previews
struct Fruit: Identifiable, Hashable {
    var id: UUID = .init()
    let name: String
    let symbol: String
    let color: FruitColor
}

/// Task model used in previews
struct Task: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

// MARK: - Preview Error Types

/// Error types used in preview examples
enum LoadError: Error, LocalizedError {
    case networkError
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case .networkError:
            "Sin conexión a internet"
        case .unauthorized:
            "No tienes permisos para acceder"
        case .serverError:
            "Error del servidor"
        }
    }
}

/// Simple error type for minimal examples
enum SimpleError: Error, LocalizedError {
    case failed

    var errorDescription: String? {
        "Algo salió mal"
    }
}
