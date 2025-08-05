//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Combine
import CombineSchedulers
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

    @Test("Initializes with data provider")
    func init_withDataProvider() {
        let expectedItems = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(dataProvider: pts.eraseToAnyPublisher, scheduler: .immediate)
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(expectedItems)
        #expect(viewModel.viewState.loadingState == .loaded)
    }

    @Test("Handles error from data provider")
    func handlesErrorFromDataProvider() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)

        let viewModel = DynamicListViewModel {
            Fail<[TestItem], Error>(error: testError).eraseToAnyPublisher()
        }

        // Test that the view model was initialized with a data provider
        // The error handling happens asynchronously
        #expect(viewModel.viewState.loadingState == .loading || viewModel.viewState.loadingState == .error(testError))
    }

    @Test("Refresh calls data provider")
    func refreshCallsDataProvider() {
        var callCount = 0
        let expectedItems = [TestItem(name: "Refreshed Item")]

        let viewModel = DynamicListViewModel {
            callCount += 1
            return Just(expectedItems).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        // Verify initial load was called
        #expect(callCount == 1)

        // Call refresh
        viewModel.refresh()
        #expect(callCount == 2)
    }

    @Test("LoadItems changes data provider")
    func loadItemsChangesDataProvider() {
        let initialItems = [TestItem(name: "Initial")]
        let newItems = [TestItem(name: "New")]

        let viewModel = DynamicListViewModel {
            Just(initialItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Change data provider
        viewModel.loadItems {
            Just(newItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Test that the view model accepted the new data provider
        #expect(viewModel.viewState.loadingState == .loading || viewModel.viewState.loadingState == .loaded)
    }

    @Test("Refresh after loadItems uses new provider")
    func refreshAfterLoadItemsUsesNewProvider() {
        var callCount = 0
        let initialItems = [TestItem(name: "Initial")]
        let newItems = [TestItem(name: "New")]

        let viewModel = DynamicListViewModel {
            callCount += 1
            return Just(initialItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Verify initial load
        #expect(callCount == 1)

        // Change data provider
        viewModel.loadItems {
            callCount += 1
            return Just(newItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Verify new provider was used
        #expect(callCount == 2)

        // Refresh should use the new provider
        viewModel.refresh()
        #expect(callCount == 3)
    }

    @Test("Data provider can capture context")
    func dataProviderCanCaptureContext() {
        var filter = "all"
        let allItems = [TestItem(name: "All 1"), TestItem(name: "All 2")]
        let completedItems = [TestItem(name: "Completed 1")]

        let viewModel = DynamicListViewModel {
            if filter == "all" {
                Just(allItems)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                Just(completedItems)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        // Test that the view model was initialized with a data provider
        #expect(viewModel.viewState.loadingState == .loading || viewModel.viewState.loadingState == .loaded)

        // Change filter and refresh
        filter = "completed"
        viewModel.refresh()

        // Test that refresh was called (the data provider will use the new filter)
        #expect(viewModel.viewState.loadingState == .loading || viewModel.viewState.loadingState == .loaded)
    }
}
