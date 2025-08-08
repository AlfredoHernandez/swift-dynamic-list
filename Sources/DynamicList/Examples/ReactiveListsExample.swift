//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Reactive Lists Example

#Preview("Reactive Lists - Publishers & Error Handling") {
    TabView {
        // Success case with delay
        DynamicListBuilder<Fruit>()
            .title("Reactive Success")
            .publisher {
                Just(fruits)
                    .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .rowContent { fruit in
                HStack {
                    Text(fruit.symbol).font(.title2)
                    Text(fruit.name).foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .detailContent { fruit in
                VStack(spacing: 20) {
                    Text(fruit.symbol).font(.system(size: 100))
                    Text(fruit.name).font(.largeTitle).bold()
                    Text("Loaded from Publisher").font(.headline).foregroundColor(.secondary)
                }
                .navigationTitle("Details")
            }
            .skeletonContent { DefaultSkeletonView() }
            .build()
            .tabItem {
                Image(systemName: "arrow.clockwise")
                Text("Success")
            }

        // Sectioned Dynamic List with reactive data
        SectionedDynamicListBuilder<Product>()
            .title("Reactive Sectioned")
            .publisher {
                // Simulate API call that returns products grouped by category
                Just([
                    products.filter { $0.category == "Electronics" },
                    products.filter { $0.category == "Audio" },
                    products.filter { $0.category == "Tablets" },
                    products.filter { $0.category == "Wearables" },
                    products.filter { $0.category == "Accessories" },
                    products.filter { $0.category == "Software & Services" },
                ])
                .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .rowContent { product in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(product.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("$\(String(format: "%.0f", product.price))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            .detailContent { product in
                VStack(spacing: 20) {
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text(product.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(product.category)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    Text("Loaded from Reactive Publisher")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Product Details")
            }
            .skeletonContent { DefaultSectionedSkeletonView() }
            .listStyle(.insetGrouped)
            .build()
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Sectioned")
            }

        // Error case with custom error view
        DynamicListBuilder<Fruit>()
            .title("Reactive Error")
            .publisher {
                Fail<[Fruit], Error>(error: LoadError.networkError)
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .rowContent { fruit in
                Text(fruit.name)
            }
            .detailContent { fruit in
                Text("Detail: \(fruit.name)")
            }
            .errorContent { error in
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash").font(.system(size: 60)).foregroundColor(.red)
                    Text("Oops!").font(.largeTitle).fontWeight(.bold)
                    Text(error.localizedDescription)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button("Retry") {}.buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            }
            .skeletonContent { DefaultSkeletonView() }
            .build()
            .tabItem {
                Image(systemName: "exclamationmark.triangle")
                Text("Error")
            }
    }
}
