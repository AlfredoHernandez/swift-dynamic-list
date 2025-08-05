//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import SwiftUI
import Testing

@Suite("DynamicList Tests")
struct DynamicListTests {
    @Test("Initializes with correct items")
    @MainActor
    func init_createsListViewWithItems() {
        let items = [
            TestItem(name: "Item 1"),
            TestItem(name: "Item 2"),
        ]

        let viewModel = DynamicListViewModel(items: items)
        let sut = DynamicList(viewModel: viewModel) { item in
            Text(item.name)
        } detailContent: { item in
            Text(item.name)
        }

        // We use a Mirror to inspect the properties of the DynamicList,
        // as we cannot directly access private properties.
        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let itemsFromMirror = viewModelFromMirror?.wrappedValue.items

        #expect(itemsFromMirror == items, "The items in the list should match the items provided on initialization.")
    }
}
