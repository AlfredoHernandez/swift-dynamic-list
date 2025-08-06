//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

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
            Text(DynamicListPresenter.errorLoadingData)
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

// MARK: - Preview Support

private enum PreviewError: Error, LocalizedError {
    case networkTimeout
    case serverError
    case noInternetConnection
    case invalidData

    var errorDescription: String? {
        switch self {
        case .networkTimeout:
            "La conexión tardó demasiado tiempo. Verifica tu conexión a internet."
        case .serverError:
            "Error del servidor. Por favor, intenta más tarde."
        case .noInternetConnection:
            "No hay conexión a internet. Verifica tu conexión y vuelve a intentar."
        case .invalidData:
            "Los datos recibidos no son válidos. Contacta al soporte técnico."
        }
    }
}

// MARK: - Previews

#Preview("Network Timeout") {
    DefaultErrorView(error: PreviewError.networkTimeout)
}

#Preview("Server Error") {
    DefaultErrorView(error: PreviewError.serverError)
}

#Preview("No Internet") {
    DefaultErrorView(error: PreviewError.noInternetConnection)
}

#Preview("Invalid Data") {
    DefaultErrorView(error: PreviewError.invalidData)
}

#Preview("Long error message") {
    struct LongError: LocalizedError {
        var errorDescription: String? {
            """
            Este es un mensaje de error muy largo que debe mostrar cómo se comporta la vista cuando tiene que mostrar múltiples líneas de texto. El mensaje debe ajustarse correctamente y ser legible.
            """
        }
    }

    return DefaultErrorView(error: LongError())
}

#Preview("Error in Navigation") {
    NavigationStack {
        DefaultErrorView(error: PreviewError.networkTimeout)
            .navigationTitle("Error")
    }
}

#Preview("Error with Background") {
    DefaultErrorView(error: PreviewError.serverError)
        .background(Color.gray.opacity(0.1))
}
