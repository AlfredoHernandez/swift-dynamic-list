//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Default detail view used when no custom detail content is provided.
///
/// This view displays a simple detail representation of the item with its
/// description and ID. It's used as a fallback when `detailContent` is not specified.
public struct DefaultDetailView<Item: Identifiable & Hashable>: View {
    private let item: Item

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(DynamicListPresenter.details)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(String(describing: item))")
                .font(.body)

            Text("\(DynamicListPresenter.idLabel)\(String(describing: item.id))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview Support

private struct PreviewItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let itemDescription: String

    var description: String {
        "\(name) - \(itemDescription)"
    }
}

// MARK: - Previews

#Preview("Simple Item Detail", traits: .sizeThatFitsLayout) {
    DefaultDetailView(item: PreviewItem(name: "Apple", itemDescription: "Red fruit"))
        .navigationTitle("Detalle")
}

#Preview("Complex Item Detail", traits: .sizeThatFitsLayout) {
    struct ComplexItem: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let value: Int

        var description: String {
            "\(title) (\(subtitle)) - Value: \(value)"
        }
    }

    return DefaultDetailView(item: ComplexItem(title: "User", subtitle: "Admin", value: 42))
        .navigationTitle("Detalle de Usuario")
}
