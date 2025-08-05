//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Advanced Usage Examples

/// Example showing how to use ViewState for more advanced UI control
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct AdvancedDynamicList<Item, RowContent, DetailContent>: View
    where Item: Identifiable & Hashable, RowContent: View, DetailContent: View
{
    @State private var viewModel: DynamicListViewModel<Item>
    private let rowContent: (Item) -> RowContent
    private let detailContent: (Item) -> DetailContent

    init(
        viewModel: DynamicListViewModel<Item>,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder detailContent: @escaping (Item) -> DetailContent,
    ) {
        _viewModel = State(initialValue: viewModel)
        self.rowContent = rowContent
        self.detailContent = detailContent
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Custom header with state information
                headerView

                // Main content based on state
                contentView
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack {
            Text("Lista Dinámica")
                .font(.largeTitle)
                .bold()

            Spacer()

            // State indicator
            stateIndicator
        }
        .padding()
        .background(Color(.systemGray6))
    }

    @ViewBuilder
    private var stateIndicator: some View {
        switch viewModel.viewState.loadingState {
        case .idle:
            Image(systemName: "circle")
                .foregroundColor(.gray)
        case .loading:
            ProgressView()
                .scaleEffect(0.8)
        case .loaded:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState.loadingState {
        case .idle:
            if viewModel.viewState.isEmpty {
                EmptyStateView(message: "No hay elementos para mostrar")
            } else {
                listView
            }
        case .loading:
            if viewModel.viewState.isEmpty {
                LoadingView()
            } else {
                // Show list with loading overlay
                ZStack {
                    listView
                    LoadingOverlay()
                }
            }
        case .loaded:
            if viewModel.viewState.isEmpty {
                EmptyStateView(message: "No se encontraron elementos")
            } else {
                listView
            }
        case let .error(error):
            if viewModel.viewState.isEmpty {
                ErrorView(error: error) {
                    // Retry action
                    viewModel.refresh()
                }
            } else {
                // Show list with error overlay
                ZStack {
                    listView
                    ErrorOverlay(error: error) {
                        viewModel.refresh()
                    }
                }
            }
        }
    }

    private var listView: some View {
        List(viewModel.viewState.items) { item in
            NavigationLink(value: item) {
                rowContent(item)
            }
        }
        .refreshable {
            viewModel.refresh()
        }
    }
}

// MARK: - Supporting Views

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Cargando...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Error")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Reintentar", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LoadingOverlay: View {
    var body: some View {
        VStack {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Actualizando...")
                    .font(.caption)
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding()
            Spacer()
        }
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct ErrorOverlay: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                VStack(alignment: .leading) {
                    Text("Error al actualizar")
                        .font(.caption)
                        .bold()
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Reintentar", action: retryAction)
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding()
            Spacer()
        }
    }
}

// MARK: - Usage Examples

/*

 Ejemplos de uso del ViewState:

 // 1. Uso básico (backward compatible)
 let viewModel = DynamicListViewModel<Task>(items: tasks)

 // Acceder al estado usando propiedades de conveniencia
 if viewModel.isLoading {
     // Mostrar loading
 }

 // 2. Uso avanzado con ViewState
 let viewModel = DynamicListViewModel<Task>(items: tasks)

 // Acceder al estado completo
 switch viewModel.viewState.loadingState {
 case .idle:
     // Estado inicial
 case .loading:
     // Cargando datos
 case .loaded:
     // Datos cargados exitosamente
 case .error(let error):
     // Error al cargar datos
 }

 // 3. Propiedades de conveniencia del ViewState
 if viewModel.viewState.shouldShowLoading {
     // Mostrar indicador de carga
 }

 if viewModel.viewState.shouldShowError {
     // Mostrar mensaje de error
 }

 if viewModel.viewState.shouldShowList {
     // Mostrar la lista
 }

 // 4. Uso en SwiftUI Views
 @State private var viewModel = DynamicListViewModel<Task>()

 var body: some View {
     Group {
         switch viewModel.viewState.loadingState {
         case .idle, .loaded:
             if viewModel.viewState.isEmpty {
                 Text("No hay elementos")
             } else {
                 List(viewModel.viewState.items) { item in
                     Text(item.title)
                 }
             }
         case .loading:
             ProgressView("Cargando...")
         case .error(let error):
             Text("Error: \(error.localizedDescription)")
         }
     }
 }

 */
