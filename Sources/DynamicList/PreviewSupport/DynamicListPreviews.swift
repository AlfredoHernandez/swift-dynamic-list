//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DynamicList Previews

#Preview("Static Data") {
    DynamicListBuilder<Fruit>()
        .items([
            Fruit(name: "Sandía", symbol: "🍉", color: .red),
            Fruit(name: "Pera", symbol: "🍐", color: .green),
            Fruit(name: "Manzana", symbol: "🍎", color: .red),
            Fruit(name: "Naranja", symbol: "🍊", color: .orange),
            Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
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
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .build()
}

#Preview("Combine Publisher - Success") {
    DynamicListBuilder<Fruit>()
        .publisher(
            Just([
                Fruit(name: "Sandía", symbol: "🍉", color: .red),
                Fruit(name: "Pera", symbol: "🍐", color: .green),
                Fruit(name: "Manzana", symbol: "🍎", color: .red),
                Fruit(name: "Naranja", symbol: "🍊", color: .orange),
                Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
                Fruit(name: "Uva", symbol: "🍇", color: .purple),
            ])
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
        )
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
                Text("Cargado desde Combine Publisher")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .build()
}

#Preview("Combine Publisher - Error (Default)") {
    DynamicListBuilder<Fruit>()
        .publisher(
            Fail<[Fruit], Error>(error: LoadError.networkError)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher(),
        )
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
        .publisher(
            Fail<[Fruit], Error>(error: SimpleError.failed)
                .eraseToAnyPublisher(),
        )
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
                Text("¡Oops!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(error.localizedDescription)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Button("Reintentar") {
                    // Aquí se podría agregar lógica de reintento
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
        .publisher(
            Fail<[Fruit], Error>(error: SimpleError.failed)
                .eraseToAnyPublisher(),
        )
        .rowContent { fruit in
            Text(fruit.name)
        }
        .detailContent { fruit in
            Text("Detail: \(fruit.name)")
        }
        .errorContent { error in
            // Vista de error minimalista
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
        .publisher(
            Just([
                Fruit(name: "Sandía", symbol: "🍉", color: .red),
                Fruit(name: "Pera", symbol: "🍐", color: .green),
                Fruit(name: "Manzana", symbol: "🍎", color: .red),
            ])
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
        )
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
            .navigationTitle("Detalles")
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
        .publisher(
            Just([
                Fruit(name: "Sandía", symbol: "🍉", color: .red),
                Fruit(name: "Pera", symbol: "🍐", color: .green),
                Fruit(name: "Manzana", symbol: "🍎", color: .red),
            ])
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
        )
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
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .skeletonContent {
            // Skeleton personalizado que coincide con el diseño real
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
                title: "Frutas Rojas",
                items: [
                    Fruit(name: "Manzana", symbol: "🍎", color: .red),
                    Fruit(name: "Sandía", symbol: "🍉", color: .red),
                    Fruit(name: "Fresa", symbol: "🍓", color: .red),
                ],
                footer: "3 frutas rojas disponibles",
            ),
            ListSection(
                title: "Frutas Verdes",
                items: [
                    Fruit(name: "Pera", symbol: "🍐", color: .green),
                    Fruit(name: "Uva Verde", symbol: "🍇", color: .green),
                ],
                footer: "2 frutas verdes disponibles",
            ),
            ListSection(
                title: "Frutas Amarillas",
                items: [
                    Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
                    Fruit(name: "Piña", symbol: "🍍", color: .yellow),
                    Fruit(name: "Limón", symbol: "🍋", color: .yellow),
                ],
                footer: "3 frutas amarillas disponibles",
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
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .title("Frutas por Color")
        .build()
}

#Preview("Sectioned List - Grouped Items") {
    SectionedDynamicListBuilder<Fruit>()
        .groupedItems(
            [
                [
                    Fruit(name: "Manzana", symbol: "🍎", color: .red),
                    Fruit(name: "Sandía", symbol: "🍉", color: .red),
                ],
                [
                    Fruit(name: "Pera", symbol: "🍐", color: .green),
                ],
                [
                    Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
                    Fruit(name: "Piña", symbol: "🍍", color: .yellow),
                    Fruit(name: "Limón", symbol: "🍋", color: .yellow),
                ],
            ],
            titles: ["Rojas", "Verdes", "Amarillas"],
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
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .title("Frutas por Categoría")
        .build()
}

#Preview("Sectioned List - Reactive") {
    SectionedDynamicListBuilder<Fruit>()
        .publisher(
            Just([
                [
                    Fruit(name: "Manzana", symbol: "🍎", color: .red),
                    Fruit(name: "Sandía", symbol: "🍉", color: .red),
                    Fruit(name: "Fresa", symbol: "🍓", color: .red),
                ],
                [
                    Fruit(name: "Pera", symbol: "🍐", color: .green),
                    Fruit(name: "Uva Verde", symbol: "🍇", color: .green),
                ],
                [
                    Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
                    Fruit(name: "Piña", symbol: "🍍", color: .yellow),
                    Fruit(name: "Limón", symbol: "🍋", color: .yellow),
                ],
            ])
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
        )
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
            .navigationTitle("Detalles")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .skeletonContent {
            DefaultSectionedSkeletonView()
        }
        .title("Frutas por Color (Reactivo)")
        .build()
}
