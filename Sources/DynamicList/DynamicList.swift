//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, and the content of the detail view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
public struct DynamicList<Item, RowContent, DetailContent>: View where Item: Identifiable & Hashable, RowContent: View, DetailContent: View {
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent

    /// Creates a new DynamicList with a view model.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    public init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading, viewModel.items.isEmpty {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error, viewModel.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error al cargar los datos")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.items) { item in
                        NavigationLink(value: item) {
                            rowContent(item)
                        }
                    }
                    .refreshable {
                        // This could be extended to support pull-to-refresh
                        viewModel.refresh()
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }
}

#Preview("Static Data") {
    enum FruitColor: CaseIterable {
        case red
        case yellow
        case green
        case orange
        case purple
    }

    struct Fruit: Identifiable, Hashable {
        var id: UUID = .init()
        let name: String
        let symbol: String
        let color: FruitColor
    }

    @Previewable @State var viewModel = DynamicListViewModel<Fruit>(
        items: [
            Fruit(name: "Sandía", symbol: "🍉", color: .red),
            Fruit(name: "Pera", symbol: "🍐", color: .green),
            Fruit(name: "Manzana", symbol: "🍎", color: .red),
            Fruit(name: "Naranja", symbol: "🍊", color: .orange),
            Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
        ],
    )
    return DynamicList(
        viewModel: viewModel,
        rowContent: { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                Text(fruit.name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        },
        detailContent: { fruit in
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
        },
    )
}

#Preview("Combine Publisher - Success") {
    enum FruitColor: CaseIterable {
        case red
        case yellow
        case green
        case orange
        case purple
    }

    struct Fruit: Identifiable, Hashable {
        var id: UUID = .init()
        let name: String
        let symbol: String
        let color: FruitColor
    }

    @Previewable @State var viewModel: DynamicListViewModel<Fruit> = {
        // Simula una carga exitosa de datos con delay
        let publisher = Just([
            Fruit(name: "Sandía", symbol: "🍉", color: .red),
            Fruit(name: "Pera", symbol: "🍐", color: .green),
            Fruit(name: "Manzana", symbol: "🍎", color: .red),
            Fruit(name: "Naranja", symbol: "🍊", color: .orange),
            Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
            Fruit(name: "Uva", symbol: "🍇", color: .purple),
        ])
        .delay(for: .seconds(2), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

        return DynamicListViewModel<Fruit>(publisher: publisher)
    }()

    return DynamicList(
        viewModel: viewModel,
        rowContent: { fruit in
            HStack {
                Text(fruit.symbol)
                    .font(.title2)
                Text(fruit.name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        },
        detailContent: { fruit in
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
        },
    )
}

#Preview("Combine Publisher - Error") {
    struct Fruit: Identifiable, Hashable {
        var id: UUID = .init()
        let name: String
        let symbol: String
    }

    enum LoadError: Error, LocalizedError {
        case networkError

        var errorDescription: String? {
            switch self {
            case .networkError:
                "No se pudo conectar al servidor"
            }
        }
    }

    @Previewable @State var viewModel: DynamicListViewModel<Fruit> = {
        // Simula un error en la carga
        let publisher = Fail<[Fruit], Error>(error: LoadError.networkError)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        return DynamicListViewModel<Fruit>(publisher: publisher)
    }()

    return DynamicList(
        viewModel: viewModel,
        rowContent: { fruit in
            Text(fruit.name)
        },
        detailContent: { fruit in
            Text("Detail: \(fruit.name)")
        },
    )
}
