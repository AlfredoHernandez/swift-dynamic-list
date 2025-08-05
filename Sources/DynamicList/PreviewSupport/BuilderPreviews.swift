//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Preview Data Models

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct PreviewUser: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let avatar: String

    static let sampleUsers = [
        PreviewUser(name: "Ana García", email: "ana@example.com", avatar: "👩‍💼"),
        PreviewUser(name: "Carlos López", email: "carlos@example.com", avatar: "👨‍💻"),
        PreviewUser(name: "María Rodríguez", email: "maria@example.com", avatar: "👩‍🎨"),
        PreviewUser(name: "Juan Pérez", email: "juan@example.com", avatar: "👨‍🔬"),
    ]
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct PreviewProduct: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let category: String

    static let sampleProducts = [
        PreviewProduct(name: "iPhone 15", price: 999.99, category: "Electronics"),
        PreviewProduct(name: "MacBook Pro", price: 1999.99, category: "Computers"),
        PreviewProduct(name: "AirPods Pro", price: 249.99, category: "Audio"),
        PreviewProduct(name: "iPad Air", price: 599.99, category: "Tablets"),
    ]
}

// MARK: - Builder Previews

#Preview("Simple Builder") {
    DynamicListBuilder<PreviewUser>()
        .withItems(PreviewUser.sampleUsers)
        .withTitle("Usuarios")
        .withRowContent { user in
            HStack {
                Text(user.avatar)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .withDetailContent { user in
            VStack(spacing: 20) {
                Text(user.avatar)
                    .font(.system(size: 80))

                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(user.email)
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Perfil")
        }
        .build()
}

#Preview("Reactive Builder") {
    let productsPublisher: AnyPublisher<[PreviewProduct], Error> = Just(PreviewProduct.sampleProducts)
        .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

    return DynamicListBuilder<PreviewProduct>()
        .withPublisher(productsPublisher)
        .withTitle("Productos")
        .withRowContent { product in
            HStack {
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    Text(product.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
        }
        .withDetailContent { product in
            VStack(spacing: 20) {
                Text("📦")
                    .font(.system(size: 80))

                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(product.category)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .navigationTitle("Detalle")
        }
        .build()
}

#Preview("Simulated Loading") {
    DynamicListBuilder<PreviewUser>()
        .withSimulatedPublisher(PreviewUser.sampleUsers, delay: 2.0)
        .withTitle("Cargando Usuarios")
        .withRowContent { user in
            HStack {
                Text(user.avatar)
                Text(user.name)
                    .font(.body)
                Spacer()
            }
        }
        .withDetailContent { user in
            Text("Detalle de \(user.name)")
                .navigationTitle("Usuario")
        }
        .build()
}

#Preview("Custom Error View") {
    let failingPublisher: AnyPublisher<[PreviewUser], Error> = Fail(error: NSError(domain: "Example", code: 404, userInfo: [
        NSLocalizedDescriptionKey: "No se pudieron cargar los usuarios",
    ]))
    .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
    .eraseToAnyPublisher()

    return DynamicListBuilder<PreviewUser>()
        .withPublisher(failingPublisher)
        .withTitle("Usuarios")
        .withRowContent { user in
            Text(user.name)
        }
        .withDetailContent { user in
            Text("Detalle de \(user.name)")
        }
        .withErrorContent { error in
            VStack(spacing: 16) {
                Text("😞")
                    .font(.system(size: 60))

                Text("¡Ups! Algo salió mal")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Reintentar") {
                    // This would trigger a refresh
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .build()
}

#Preview("Default Views") {
    DynamicListBuilder<PreviewUser>()
        .withItems(PreviewUser.sampleUsers)
        .withTitle("Vistas por Defecto")
        .build()
}

// MARK: - Factory Method Previews

#Preview("Simple Factory") {
    DynamicListBuilder.simple(
        items: PreviewUser.sampleUsers,
        rowContent: { user in
            HStack {
                Text(user.avatar)
                Text(user.name)
                Spacer()
            }
        },
        detailContent: { user in
            Text("Detalle de \(user.name)")
                .navigationTitle("Usuario")
        },
    )
}

#Preview("Reactive Factory") {
    let publisher: AnyPublisher<[PreviewProduct], Error> = Just(PreviewProduct.sampleProducts)
        .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

    return DynamicListBuilder.reactive(
        publisher: publisher,
        rowContent: { product in
            HStack {
                Text(product.name)
                Spacer()
                Text("$\(product.price, specifier: "%.2f")")
            }
        },
        detailContent: { product in
            Text("Detalle de \(product.name)")
                .navigationTitle("Producto")
        },
    )
}

#Preview("Simulated Factory") {
    DynamicListBuilder.simulated(
        items: PreviewUser.sampleUsers,
        delay: 2.0,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detalle de \(user.name)")
        },
    )
}
