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

        // Test backward compatibility properties
        #expect(viewModel.items == items)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)

        // Test viewState directly
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.isLoading)
        #expect(viewModel.viewState.error == nil)
    }

    @Test("Initializes with an empty array by default")
    func init_withDefaultEmptyArray() {
        let viewModel = DynamicListViewModel<TestItem>()

        // Test backward compatibility properties
        #expect(viewModel.items.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)

        // Test viewState directly
        #expect(viewModel.viewState.items.isEmpty)
        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
    }

    @Test("ViewState provides correct convenience properties")
    func viewState_convenienceProperties() {
        let items = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let viewModel = DynamicListViewModel(items: items)

        // Test state-specific properties
        #expect(viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.isEmpty)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
        #expect(viewModel.viewState.isLoaded == false) // idle state is not loaded
    }
}
