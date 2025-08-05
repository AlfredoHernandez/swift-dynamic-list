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
