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
                NavigationLink("View User Detail") {
                    DefaultDetailView(item: ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"))
                        .navigationTitle("User Detail")
                }

                NavigationLink("View Product Detail") {
                    DefaultDetailView(item: ShowcaseProduct(name: "iPhone 15", category: "Electronics", price: 999.99))
                        .navigationTitle("Product Detail")
                }
            }

            Section("Skeleton Views") {
                NavigationLink("Simple Skeleton") {
                    DefaultSkeletonView()
                        .navigationTitle("Loading...")
                }

                NavigationLink("Sectioned Skeleton") {
                    DefaultSectionedSkeletonView()
                        .navigationTitle("Loading...")
                }
            }

            Section("Error Views") {
                NavigationLink("Network Error") {
                    DefaultErrorView(error: ShowcaseNetworkError.timeout)
                        .navigationTitle("Error")
                }

                NavigationLink("Server Error") {
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
    .navigationTitle("Users")
}

#Preview("Default Detail Views") {
    NavigationStack {
        VStack(spacing: 20) {
            DefaultDetailView(item: ShowcaseUser(name: "Ana García", email: "ana@example.com", role: "Admin"))

            Divider()

            DefaultDetailView(item: ShowcaseProduct(name: "iPhone 15", category: "Electronics", price: 999.99))
        }
        .padding()
        .navigationTitle("Details")
    }
}

#Preview("Skeleton Loading States") {
    NavigationStack {
        VStack(spacing: 20) {
            Text("Simple Skeleton")
                .font(.headline)
            DefaultSkeletonView()
                .frame(height: 300)

            Divider()

            Text("Sectioned Skeleton")
                .font(.headline)
            DefaultSectionedSkeletonView()
                .frame(height: 300)
        }
        .padding()
        .navigationTitle("Loading States")
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
        .navigationTitle("Error States")
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
            "Connection timed out. Please check your internet connection."
        case .serverError:
            "Server error. Please try again later."
        case .noConnection:
            "No internet connection. Please check your connection and try again."
        }
    }
}
