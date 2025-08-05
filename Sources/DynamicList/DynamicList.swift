//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// A view that displays a list of items and navigates to a detail view for each item.
///
/// This view is generic over the type of item, the content of the row, and the content of the detail view.
/// The `Item` type must conform to the `Identifiable` and `Hashable` protocols.
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
            List(viewModel.items) { item in
                NavigationLink(value: item) {
                    rowContent(item)
                }
            }
            .navigationDestination(for: Item.self) { item in
                detailContent(item)
            }
        }
    }
}

#Preview {
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
            Text("Fruit name: \(fruit.name)")
        },
        detailContent: { fruit in
            Text("Detail: \(fruit.name) \(fruit.symbol)")
        },
    )
}
