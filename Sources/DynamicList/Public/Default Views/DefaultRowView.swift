//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Default row view used when no custom row content is provided.
///
/// This view displays a simple representation of the item with its description
/// and ID. It's used as a fallback when `rowContent` is not specified.
public struct DefaultRowView<Item: Identifiable & Hashable>: View {
    private let item: Item

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(String(describing: item))
                .font(.body)
            Text("\(DynamicListPresenter.idLabel)\(String(describing: item.id))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
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

#Preview("Simple Item") {
    List {
        DefaultRowView(item: PreviewItem(name: "Apple", itemDescription: "Red fruit"))
        DefaultRowView(item: PreviewItem(name: "Banana", itemDescription: "Yellow fruit"))
        DefaultRowView(item: PreviewItem(name: "Orange", itemDescription: "Orange fruit"))
    }
}

#Preview("Complex Item") {
    struct ComplexItem: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let value: Int

        var description: String {
            "\(title) (\(subtitle)) - Value: \(value)"
        }
    }

    return List {
        DefaultRowView(item: ComplexItem(title: "User", subtitle: "Admin", value: 42))
        DefaultRowView(item: ComplexItem(title: "Product", subtitle: "Electronics", value: 100))
        DefaultRowView(item: ComplexItem(title: "Order", subtitle: "Pending", value: 7))
    }
}
