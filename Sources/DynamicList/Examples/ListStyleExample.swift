//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Example demonstrating different list styles in DynamicList.
///
/// This example shows how to customize the appearance of lists using different
/// list styles like `.plain`, `.inset`, `.grouped`, etc.
struct ListStyleExample: View {
    struct Product: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let price: Double
        let category: String
    }

    private let products = [
        Product(name: "iPhone 15", price: 999.0, category: "Electronics"),
        Product(name: "MacBook Pro", price: 1999.0, category: "Electronics"),
        Product(name: "AirPods Pro", price: 249.0, category: "Audio"),
        Product(name: "iPad Air", price: 599.0, category: "Tablets"),
        Product(name: "Apple Watch", price: 399.0, category: "Wearables"),
    ]

    var body: some View {
        TabView {
            // Plain Style
            DynamicListBuilder<Product>()
                .title("Plain Style")
                .items(products)
                .listStyle(.plain)
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
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .detailContent { product in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(product.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(product.category)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Product Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Plain")
                }

            // Inset Style
            DynamicListBuilder<Product>()
                .title("Inset Grouped Style")
                .items(products)
                .listStyle(.insetGrouped)
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
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .detailContent { product in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(product.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(product.category)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Product Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "list.bullet.indent")
                    Text("Inset")
                }

            // Automatic Style
            DynamicListBuilder<Product>()
                .title("Automatic Style")
                .items(products)
                .listStyle(.automatic)
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
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .detailContent { product in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(product.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(product.category)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Product Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "list.bullet.circle")
                    Text("Automatic")
                }
        }
    }
}

#Preview {
    ListStyleExample()
}
