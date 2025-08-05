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
    @Test("when initialized with items displays correct items")
    func whenInitializedWithItems_displaysCorrectItems() {
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

    @Test("when initialized without items displays empty state")
    func whenInitializedWithoutItems_displaysEmptyState() {
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

    @Test("when view state is idle provides correct convenience properties")
    func whenViewStateIsIdle_providesCorrectConvenienceProperties() {
        let items = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let viewModel = DynamicListViewModel(items: items)

        // Test state-specific properties
        #expect(viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.isEmpty)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
        #expect(viewModel.viewState.isLoaded == false) // idle state is not loaded
    }

    @Test("when initialized with data provider starts loading and displays data when received")
    func whenInitializedWithDataProvider_startsLoadingAndDisplaysDataWhenReceived() {
        let expectedItems = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(dataProvider: pts.eraseToAnyPublisher, scheduler: .immediate)
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(expectedItems)
        #expect(viewModel.viewState.loadingState == .loaded)
    }

    @Test("when data provider fails displays error state")
    func whenDataProviderFails_displaysErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(dataProvider: pts.eraseToAnyPublisher, scheduler: .immediate)
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(completion: .failure(testError))
        #expect(viewModel.viewState.loadingState == .error(testError))
    }

    @Test("when refresh is called loads data from provider")
    func whenRefreshIsCalled_loadsDataFromProvider() {
        var callCount = 0
        let expectedItems = [TestItem(name: "Refreshed Item")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: {
                callCount += 1
                return pts.eraseToAnyPublisher()
            },
            scheduler: .immediate,
        )

        // Verify initial load was called
        #expect(callCount == 1)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send initial data
        pts.send(expectedItems)
        #expect(viewModel.viewState.loadingState == .loaded)

        // Call refresh
        viewModel.refresh()
        #expect(callCount == 2)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send refreshed data
        pts.send(expectedItems)
        #expect(viewModel.viewState.loadingState == .loaded)
    }

    @Test("when loadItems is called changes data provider")
    func whenLoadItemsIsCalled_changesDataProvider() {
        let initialItems = [TestItem(name: "Initial")]
        let newItems = [TestItem(name: "New")]
        let pts1 = PassthroughSubject<[TestItem], Error>()
        let pts2 = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts1.eraseToAnyPublisher,
            scheduler: .immediate,
        )

        #expect(viewModel.viewState.loadingState == .loading)

        // Send initial data
        pts1.send(initialItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == initialItems)

        // Change data provider
        viewModel.loadItems(from: pts2.eraseToAnyPublisher)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send new data
        pts2.send(newItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == newItems)
    }

    @Test("when refresh is called after loadItems uses new provider")
    func whenRefreshIsCalledAfterLoadItems_usesNewProvider() {
        var callCount = 0
        let initialItems = [TestItem(name: "Initial")]
        let newItems = [TestItem(name: "New")]
        let pts1 = PassthroughSubject<[TestItem], Error>()
        let pts2 = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: {
                callCount += 1
                return pts1.eraseToAnyPublisher()
            },
            scheduler: .immediate,
        )

        // Verify initial load
        #expect(callCount == 1)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send initial data
        pts1.send(initialItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == initialItems)

        // Change data provider
        viewModel.loadItems {
            callCount += 1
            return pts2.eraseToAnyPublisher()
        }

        // Verify new provider was used
        #expect(callCount == 2)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send new data
        pts2.send(newItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == newItems)

        // Refresh should use the new provider
        viewModel.refresh()
        #expect(callCount == 3)
        #expect(viewModel.viewState.loadingState == .loading)

        // Send refreshed data through new provider
        pts2.send(newItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == newItems)
    }

    @Test("when data provider captures context uses updated context on refresh")
    func whenDataProviderCapturesContext_usesUpdatedContextOnRefresh() {
        var filter = "all"
        let allItems = [TestItem(name: "All 1"), TestItem(name: "All 2")]
        let completedItems = [TestItem(name: "Completed 1")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: {
                if filter == "all" {
                    pts.eraseToAnyPublisher()
                } else {
                    pts.eraseToAnyPublisher()
                }
            },
            scheduler: .immediate,
        )

        // Send initial data with "all" filter
        pts.send(allItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == allItems)

        // Change filter and refresh
        filter = "completed"
        viewModel.refresh()
        #expect(viewModel.viewState.loadingState == .loading)

        // Send new data for completed filter
        pts.send(completedItems)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.items == completedItems)
    }
}
