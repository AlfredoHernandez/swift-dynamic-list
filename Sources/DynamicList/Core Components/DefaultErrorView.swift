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

// MARK: - Preview Support

private enum PreviewError: Error, LocalizedError {
    case networkTimeout

    var errorDescription: String? {
        switch self {
        case .networkTimeout:
            "La conexión tardó demasiado tiempo. Verifica tu conexión a internet."
        }
    }
}

// MARK: - Previews

#Preview("Network error") {
    DefaultErrorView(error: PreviewError.networkTimeout)
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
