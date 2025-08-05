//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Default error view used when no custom error view is provided
public struct DefaultErrorView: View {
    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    public var body: some View {
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
    }
}

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, the content of the detail view,
/// and optionally the content of the error view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
public struct DynamicList<Item, RowContent, DetailContent, ErrorContent>: View where Item: Identifiable & Hashable, RowContent: View, DetailContent: View,
    ErrorContent: View
{
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent
    private let errorContent: ((Error) -> ErrorContent)?

    /// Creates a new DynamicList with a view model and custom error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    ///   - errorContent: A view builder that creates the error view when loading fails.
    public init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        self.errorContent = errorContent
    }

    /// Creates a new DynamicList with a view model using the default error view.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that contains the items to display.
    ///   - rowContent: A view builder that creates the view for each row in the list.
    ///   - detailContent: A view builder that creates the detail view for an item.
    public init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) where ErrorContent == DefaultErrorView {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
        errorContent = nil
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.viewState.shouldShowLoading {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.viewState.shouldShowError {
                    errorView
                } else {
                    List(viewModel.viewState.items) { item in
                        NavigationLink(value: item) { rowContent(item) }
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorContent,
           let error = viewModel.viewState.error
        {
            errorContent(error)
        } else if let error = viewModel.viewState.error {
            DefaultErrorView(error: error)
        }
    }
}

// MARK: - Preview Models

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

struct Task: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

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

enum SimpleError: Error, LocalizedError {
    case failed

    var errorDescription: String? {
        "Algo salió mal"
    }
}

#Preview("Static Data") {
    @Previewable @State var viewModel = DynamicListViewModel<Fruit>(
        items: [
            Fruit(name: "Sandía", symbol: "🍉", color: .red),
            Fruit(name: "Pera", symbol: "🍐", color: .green),
            Fruit(name: "Manzana", symbol: "🍎", color: .red),
            Fruit(name: "Naranja", symbol: "🍊", color: .orange),
            Fruit(name: "Plátano", symbol: "🍌", color: .yellow),
        ],
    )
    DynamicList(
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

    DynamicList(
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

#Preview("Combine Publisher - Error (Default)") {
    @Previewable @State var viewModel: DynamicListViewModel<Fruit> = {
        // Simula un error en la carga
        let publisher = Fail<[Fruit], Error>(error: LoadError.networkError)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        return DynamicListViewModel<Fruit>(publisher: publisher)
    }()

    DynamicList(
        viewModel: viewModel,
        rowContent: { fruit in
            Text(fruit.name)
        },
        detailContent: { fruit in
            Text("Detail: \(fruit.name)")
        },
    )
}

#Preview("Custom Error View") {
    @Previewable @State var viewModel: DynamicListViewModel<Fruit> = {
        let publisher = Fail<[Fruit], Error>(error: LoadError.unauthorized)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        return DynamicListViewModel<Fruit>(publisher: publisher)
    }()

    DynamicList(
        viewModel: viewModel,
        rowContent: { fruit in
            Text(fruit.name)
        },
        detailContent: { fruit in
            Text("Detail: \(fruit.name)")
        },
        errorContent: { error in
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
        },
    )
}

#Preview("Minimal Custom Error") {
    @Previewable @State var viewModel: DynamicListViewModel<Task> = {
        let publisher = Fail<[Task], Error>(error: SimpleError.failed)
            .eraseToAnyPublisher()
        return DynamicListViewModel<Task>(publisher: publisher)
    }()

    DynamicList(
        viewModel: viewModel,
        rowContent: { task in
            Text(task.title)
        },
        detailContent: { task in
            Text("Detail: \(task.title)")
        },
        errorContent: { error in
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
        },
    )
}
