//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

@Suite("DynamicListViewModel Tests")
struct DynamicListViewModelTests {
    @Test("Initializes with items")
    func init_withItems() {
        let items = [TestItem(name: "Item 1")]
        let viewModel = DynamicListViewModel(items: items)

        #expect(viewModel.items == items)
    }

    @Test("Initializes with an empty array by default")
    func init_withDefaultEmptyArray() {
        let viewModel = DynamicListViewModel<TestItem>()

        #expect(viewModel.items.isEmpty)
    }
}
