//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

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

/// Error types used in preview examples
enum LoadError: Error, LocalizedError {
    case networkError
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case .networkError:
            "No internet connection"
        case .unauthorized:
            "You don't have permission to access"
        case .serverError:
            "Server error"
        }
    }
}

/// Simple error type for minimal examples
enum SimpleError: Error, LocalizedError {
    case failed

    var errorDescription: String? {
        "Something went wrong"
    }
}

// MARK: - DynamicList Previews

#Preview("Static Data") {
    DynamicListBuilder<Fruit>()
        .items([
            Fruit(name: "Watermelon", symbol: "🍉", color: .red),
            Fruit(name: "Pear", symbol: "🍐", color: .green),
            Fruit(name: "Apple", symbol: "🍎", color: .red),
            Fruit(name: "Orange", symbol: "🍊", color: .orange),
            Fruit(name: "Banana", symbol: "🍌", color: .yellow),
        ])
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                Text(fruit.name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .build()
}

#Preview("Combine Publisher - Success") {
    DynamicListBuilder<Fruit>()
        .publisher {
            Just([
                Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                Fruit(name: "Pear", symbol: "🍐", color: .green),
                Fruit(name: "Apple", symbol: "🍎", color: .red),
                Fruit(name: "Orange", symbol: "🍊", color: .orange),
                Fruit(name: "Banana", symbol: "🍌", color: .yellow),
                Fruit(name: "Grape", symbol: "🍇", color: .purple),
            ])
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                Text(fruit.name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Loaded from Combine Publisher")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .build()
}

#Preview("Combine Publisher - Error (Default)") {
    DynamicListBuilder<Fruit>()
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
        .build()
}

#Preview("Custom Error") {
    DynamicListBuilder<Fruit>()
        .publisher {
            Fail<[Fruit], Error>(error: SimpleError.failed)
                .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            Text(fruit.name)
        }
        .detailContent { fruit in
            Text("Detail: \(fruit.name)")
        }
        .errorContent { error in
            // Vista de error personalizada
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                Text("Oops!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(error.localizedDescription)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Button("Retry") {
                    // Retry logic could be added here
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial)
        }
        .skeletonContent {
            DefaultSkeletonView()
        }
        .build()
}

#Preview("Minimal Custom Error") {
    DynamicListBuilder<Fruit>()
        .publisher {
            Fail<[Fruit], Error>(error: SimpleError.failed)
                .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            Text(fruit.name)
        }
        .detailContent { fruit in
            Text("Detail: \(fruit.name)")
        }
        .errorContent { error in
            // Minimalist error view
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .skeletonContent {
            DefaultSkeletonView()
        }
        .build()
}

#Preview("Skeleton Loading") {
    DynamicListBuilder<Fruit>()
        .publisher {
            Just([
                Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                Fruit(name: "Pear", symbol: "🍐", color: .green),
                Fruit(name: "Apple", symbol: "🍎", color: .red),
            ])
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(fruit.name)
                        .font(.headline)
                    Text("Color: \(String(describing: fruit.color))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .skeletonContent {
            DefaultSkeletonView()
        }
        .build()
}

#Preview("Custom Skeleton with Builder") {
    DynamicListBuilder<Fruit>()
        .publisher {
            Just([
                Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                Fruit(name: "Pear", symbol: "🍐", color: .green),
                Fruit(name: "Apple", symbol: "🍎", color: .red),
            ])
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(fruit.name)
                        .font(.headline)
                    Text("Color: \(String(describing: fruit.color))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .skeletonContent {
            // Custom skeleton that matches the real design
            List(0 ..< 8, id: \.self) { _ in
                HStack {
                    // Skeleton para el emoji
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)

                    VStack(alignment: .leading, spacing: 6) {
                        // Skeleton para el nombre
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 18)
                            .frame(maxWidth: .infinity * 0.6)

                        // Skeleton para el color
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .frame(maxWidth: .infinity * 0.4)
                    }

                    Spacer()
                }
                .padding(.vertical, 6)
            }
            .redacted(reason: .placeholder)
        }
        .build()
}

#Preview("Sectioned List - Static") {
    SectionedDynamicListBuilder<Fruit>()
        .sections([
            ListSection(
                title: "Red Fruits",
                items: [
                    Fruit(name: "Apple", symbol: "🍎", color: .red),
                    Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                    Fruit(name: "Strawberry", symbol: "🍓", color: .red),
                ],
                footer: "3 red fruits available",
            ),
            ListSection(
                title: "Green Fruits",
                items: [
                    Fruit(name: "Pear", symbol: "🍐", color: .green),
                    Fruit(name: "Green Grape", symbol: "🍇", color: .green),
                ],
                footer: "2 green fruits available",
            ),
            ListSection(
                title: "Yellow Fruits",
                items: [
                    Fruit(name: "Banana", symbol: "🍌", color: .yellow),
                    Fruit(name: "Pineapple", symbol: "🍍", color: .yellow),
                    Fruit(name: "Lemon", symbol: "🍋", color: .yellow),
                ],
                footer: "3 yellow fruits available",
            ),
        ])
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(fruit.name)
                        .font(.headline)
                    Text("Color: \(String(describing: fruit.color))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .title("Fruits by Color")
        .build()
}

#Preview("Sectioned List - Grouped Items") {
    SectionedDynamicListBuilder<Fruit>()
        .groupedItems(
            [
                [
                    Fruit(name: "Apple", symbol: "🍎", color: .red),
                    Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                ],
                [
                    Fruit(name: "Pear", symbol: "🍐", color: .green),
                ],
                [
                    Fruit(name: "Banana", symbol: "🍌", color: .yellow),
                    Fruit(name: "Pineapple", symbol: "🍍", color: .yellow),
                    Fruit(name: "Lemon", symbol: "🍋", color: .yellow),
                ],
            ],
            titles: ["Red", "Green", "Yellow"],
        )
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                Text(fruit.name)
                    .font(.headline)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .title("Fruits by Category")
        .build()
}

#Preview("Sectioned List - Reactive") {
    SectionedDynamicListBuilder<Fruit>()
        .publisher {
            Just([
                [
                    Fruit(name: "Apple", symbol: "🍎", color: .red),
                    Fruit(name: "Watermelon", symbol: "🍉", color: .red),
                    Fruit(name: "Strawberry", symbol: "🍓", color: .red),
                ],
                [
                    Fruit(name: "Pear", symbol: "🍐", color: .green),
                    Fruit(name: "Green Grape", symbol: "🍇", color: .green),
                ],
                [
                    Fruit(name: "Banana", symbol: "🍌", color: .yellow),
                    Fruit(name: "Pineapple", symbol: "🍍", color: .yellow),
                    Fruit(name: "Lemon", symbol: "🍋", color: .yellow),
                ],
            ])
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .rowContent { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(fruit.name)
                        .font(.headline)
                    Text("Color: \(String(describing: fruit.color))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .detailContent { fruit in
            VStack(spacing: 20) {
                Text(fruit.symbol)
                    .font(.system(size: 100))
                Text(fruit.name)
                    .font(.largeTitle)
                    .bold()
                Text("Color: \(String(describing: fruit.color))")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .skeletonContent {
            DefaultSectionedSkeletonView()
        }
        .title("Fruits by Color (Reactive)")
        .build()
}
