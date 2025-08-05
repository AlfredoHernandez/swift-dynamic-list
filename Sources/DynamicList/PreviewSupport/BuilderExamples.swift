//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Example Data Models

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let avatar: String

    static let sampleUsers = [
        User(name: "Ana García", email: "ana@example.com", avatar: "👩‍💼"),
        User(name: "Carlos López", email: "carlos@example.com", avatar: "👨‍💻"),
        User(name: "María Rodríguez", email: "maria@example.com", avatar: "👩‍🎨"),
        User(name: "Juan Pérez", email: "juan@example.com", avatar: "👨‍🔬"),
    ]
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let category: String

    static let sampleProducts = [
        Product(name: "iPhone 15", price: 999.99, category: "Electronics"),
        Product(name: "MacBook Pro", price: 1999.99, category: "Computers"),
        Product(name: "AirPods Pro", price: 249.99, category: "Audio"),
        Product(name: "iPad Air", price: 599.99, category: "Tablets"),
    ]
}

// MARK: - Builder Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct BuilderExamplesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Builder Pattern Examples") {
                    NavigationLink("Simple List") {
                        SimpleListExample()
                    }

                    NavigationLink("Reactive List") {
                        ReactiveListExample()
                    }

                    NavigationLink("Simulated Loading") {
                        SimulatedLoadingExample()
                    }

                    NavigationLink("Custom Error View") {
                        CustomErrorExample()
                    }

                    NavigationLink("Complete Example") {
                        CompleteExample()
                    }
                }
            }
            .navigationTitle("DynamicList Builder")
        }
    }
}

// MARK: - Example 1: Simple List

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct SimpleListExample: View {
    var body: some View {
        DynamicListBuilder<User>()
            .items(User.sampleUsers)
            .title("Usuarios")
            .rowContent { user in
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
            .detailContent { user in
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
                .navigationTitle(DynamicListPresenter.profile)
            }
            .buildWithoutNavigation()
    }
}

// MARK: - Example 2: Reactive List

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct ReactiveListExample: View {
    private var productsPublisher: AnyPublisher<[Product], Error> {
        // Simulate API call
        Just(Product.sampleProducts)
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var body: some View {
        DynamicListBuilder<Product>()
            .publisher(productsPublisher)
            .title("Productos")
            .rowContent { product in
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
            .detailContent { product in
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
                .navigationTitle(DynamicListPresenter.detail)
            }
            .buildWithoutNavigation()
    }
}

// MARK: - Example 3: Simulated Loading

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct SimulatedLoadingExample: View {
    var body: some View {
        DynamicListBuilder<User>()
            .simulatedPublisher(User.sampleUsers, delay: 2.0)
            .title("Cargando Usuarios")
            .rowContent { user in
                HStack {
                    Text(user.avatar)
                    Text(user.name)
                        .font(.body)
                    Spacer()
                }
            }
            .detailContent { user in
                Text("Detalle de \(user.name)")
                    .navigationTitle(DynamicListPresenter.userDetail)
            }
            .buildWithoutNavigation()
    }
}

// MARK: - Example 4: Custom Error View

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct CustomErrorExample: View {
    private var failingPublisher: AnyPublisher<[User], Error> {
        Fail(error: NSError(domain: "Example", code: 404, userInfo: [
            NSLocalizedDescriptionKey: "No se pudieron cargar los usuarios",
        ]))
        .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    var body: some View {
        DynamicListBuilder<User>()
            .publisher(failingPublisher)
            .title("Usuarios")
            .rowContent { user in
                Text(user.name)
            }
            .detailContent { user in
                Text("Detalle de \(user.name)")
            }
            .errorContent { error in
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

                    Button(DynamicListPresenter.retry) {
                        // This would trigger a refresh
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buildWithoutNavigation()
    }
}

// MARK: - Example 5: Complete Example

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct CompleteExample: View {
    private var mixedPublisher: AnyPublisher<[Product], Error> {
        // Simulate mixed success/failure scenarios
        let random = Int.random(in: 1 ... 3)

        switch random {
        case 1:
            return Just(Product.sampleProducts)
                .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case 2:
            return Fail(error: NSError(domain: "Network", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Error del servidor",
            ]))
            .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        default:
            return Just([])
                .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    var body: some View {
        DynamicListBuilder<Product>()
            .publisher(mixedPublisher)
            .title("Productos Completo")
            .rowContent { product in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Text("Available")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 8)
            }
            .detailContent { product in
                ScrollView {
                    VStack(spacing: 24) {
                        Text("📦")
                            .font(.system(size: 100))

                        VStack(spacing: 8) {
                            Text(product.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Text(product.category)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }

                        VStack(spacing: 16) {
                            HStack {
                                Text("Price:")
                                    .font(.headline)
                                Spacer()
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }

                            Divider()

                            HStack {
                                Text("Category:")
                                    .font(.headline)
                                Spacer()
                                Text(product.category)
                                    .font(.body)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)

                        Button("Buy Now") {
                            // Purchase action
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle(DynamicListPresenter.productDetail)
            }
            .errorContent { error in
                VStack(spacing: 20) {
                    Text("⚠️")
                        .font(.system(size: 80))

                    Text("Error Loading")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        Button(DynamicListPresenter.retry) {
                            // Retry action
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel") {
                            // Cancel action
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buildWithoutNavigation()
    }
}

// MARK: - Convenience Factory Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct FactoryExamplesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Factory Methods") {
                    NavigationLink("Simple Factory") {
                        SimpleFactoryExample()
                    }

                    NavigationLink("Reactive Factory") {
                        ReactiveFactoryExample()
                    }

                    NavigationLink("Simulated Factory") {
                        SimulatedFactoryExample()
                    }
                }
            }
            .navigationTitle("Factory Methods")
        }
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct SimpleFactoryExample: View {
    var body: some View {
        DynamicListBuilder.simple(
            items: User.sampleUsers,
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
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct ReactiveFactoryExample: View {
    private var publisher: AnyPublisher<[Product], Error> {
        Just(Product.sampleProducts)
            .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var body: some View {
        DynamicListBuilder.reactive(
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
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct SimulatedFactoryExample: View {
    var body: some View {
        DynamicListBuilder.simulated(
            items: User.sampleUsers,
            delay: 2.0,
            rowContent: { user in
                Text(user.name)
            },
            detailContent: { user in
                Text("Detalle de \(user.name)")
            },
        )
    }
}

// MARK: - Previews

#Preview("Builder Examples") {
    BuilderExamplesView()
}

#Preview("Factory Examples") {
    FactoryExamplesView()
}
