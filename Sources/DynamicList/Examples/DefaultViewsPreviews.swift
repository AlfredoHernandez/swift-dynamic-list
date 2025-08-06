//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Preview Models

private struct ShowcaseUser: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let role: String

    var description: String {
        "\(name) (\(email)) - \(role)"
    }
}

private struct ShowcaseProduct: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double

    var description: String {
        "\(name) - \(category) - $\(String(format: "%.2f", price))"
    }
}

// MARK: - Default Views Showcase

#Preview("Default Views Showcase") {
    NavigationStack {
        List {
            Section("Default Row Views") {
                DefaultRowView(item: ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"))
                DefaultRowView(item: ShowcaseUser(name: "Bob Smith", email: "bob@example.com", role: "User"))
                DefaultRowView(item: ShowcaseProduct(name: "iPhone 15", category: "Electronics", price: 999.99))
            }

            Section("Default Detail Views") {
                NavigationLink("Ver Detalle de Usuario") {
                    DefaultDetailView(item: ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"))
                        .navigationTitle("Detalle de Usuario")
                }

                NavigationLink("Ver Detalle de Producto") {
                    DefaultDetailView(item: ShowcaseProduct(name: "iPhone 15", category: "Electronics", price: 999.99))
                        .navigationTitle("Detalle de Producto")
                }
            }

            Section("Skeleton Views") {
                NavigationLink("Skeleton Simple") {
                    DefaultSkeletonView()
                        .navigationTitle("Cargando...")
                }

                NavigationLink("Skeleton con Secciones") {
                    DefaultSectionedSkeletonView()
                        .navigationTitle("Cargando...")
                }
            }

            Section("Error Views") {
                NavigationLink("Error de Red") {
                    DefaultErrorView(error: ShowcaseNetworkError.timeout)
                        .navigationTitle("Error")
                }

                NavigationLink("Error del Servidor") {
                    DefaultErrorView(error: ShowcaseNetworkError.serverError)
                        .navigationTitle("Error")
                }
            }
        }
        .navigationTitle("Default Views")
    }
}

#Preview("Default Row Views in List") {
    let users = [
        ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"),
        ShowcaseUser(name: "Bob Smith", email: "bob@example.com", role: "User"),
        ShowcaseUser(name: "Carlos López", email: "carlos@example.com", role: "Manager"),
    ]

    List(users) { user in
        DefaultRowView(item: user)
    }
    .navigationTitle("Usuarios")
}

#Preview("Default Detail Views") {
    NavigationStack {
        VStack(spacing: 20) {
            DefaultDetailView(item: ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"))

            Divider()

            DefaultDetailView(item: ShowcaseProduct(name: "iPhone 15", category: "Electronics", price: 999.99))
        }
        .padding()
        .navigationTitle("Detalles")
    }
}

#Preview("Skeleton Loading States") {
    NavigationStack {
        VStack(spacing: 20) {
            Text("Skeleton Simple")
                .font(.headline)
            DefaultSkeletonView()
                .frame(height: 300)

            Divider()

            Text("Skeleton con Secciones")
                .font(.headline)
            DefaultSectionedSkeletonView()
                .frame(height: 300)
        }
        .padding()
        .navigationTitle("Estados de Carga")
    }
}

#Preview("Error States") {
    NavigationStack {
        VStack(spacing: 20) {
            DefaultErrorView(error: ShowcaseNetworkError.timeout)
                .frame(height: 200)

            Divider()

            DefaultErrorView(error: ShowcaseNetworkError.serverError)
                .frame(height: 200)
        }
        .padding()
        .navigationTitle("Estados de Error")
    }
}

// MARK: - Preview Error Types

private enum ShowcaseNetworkError: LocalizedError {
    case timeout
    case serverError
    case noConnection

    var errorDescription: String? {
        switch self {
        case .timeout:
            "La conexión tardó demasiado tiempo. Verifica tu conexión a internet."
        case .serverError:
            "Error del servidor. Por favor, intenta más tarde."
        case .noConnection:
            "No hay conexión a internet. Verifica tu conexión y vuelve a intentar."
        }
    }
}
