//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DynamicList Previews

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
