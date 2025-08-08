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
    @Test("Init displays correct items with provided items")
    func init_displaysCorrectItemsWithProvidedItems() {
        let items = [TestItem(name: "Item 1")]
        let viewModel = DynamicListViewModel(
            items: items,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

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

    @Test("Init displays empty state without items")
    func init_displaysEmptyStateWithoutItems() {
        let viewModel = DynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

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

    @Test("ViewState provides correct convenience properties on idle state")
    func viewState_providesCorrectConveniencePropertiesOnIdleState() {
        let items = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let viewModel = DynamicListViewModel(
            items: items,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        // Test state-specific properties
        #expect(viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.isEmpty)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
        #expect(viewModel.viewState.isLoaded == false) // idle state is not loaded
    }

    @Test("Init starts loading and displays data with data provider")
    func init_startsLoadingAndDisplaysDataWithDataProvider() {
        let expectedItems = [TestItem(name: "Item 1"), TestItem(name: "Item 2")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(expectedItems)
        #expect(viewModel.viewState.loadingState == .loaded)
    }

    @Test("Init displays error state on data provider failure")
    func init_displaysErrorStateOnDataProviderFailure() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(completion: .failure(testError))
        #expect(viewModel.viewState.loadingState == .error(testError))
    }

    @Test("Refresh loads data from provider")
    func refresh_loadsDataFromProvider() {
        var callCount = 0
        let expectedItems = [TestItem(name: "Refreshed Item")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: {
                callCount += 1
                return pts.eraseToAnyPublisher()
            },
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()

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

    @Test("LoadItems changes data provider")
    func loadItems_changesDataProvider() {
        let initialItems = [TestItem(name: "Initial")]
        let newItems = [TestItem(name: "New")]
        let pts1 = PassthroughSubject<[TestItem], Error>()
        let pts2 = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts1.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()

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

    @Test("Refresh uses new provider after loadItems")
    func refresh_usesNewProviderAfterLoadItems() {
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
            ioScheduler: .immediate,
        )
        viewModel.loadData()

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

    @Test("Refresh uses updated context when data provider captures context")
    func refresh_usesUpdatedContextWhenDataProviderCapturesContext() {
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
            ioScheduler: .immediate,
        )
        viewModel.loadData()

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
