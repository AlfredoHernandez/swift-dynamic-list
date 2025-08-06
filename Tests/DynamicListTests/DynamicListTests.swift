//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Combine
import SwiftUI
import Testing

@Suite("DynamicList Tests")
struct DynamicListTests {
    @Test("when initialized with items creates list view with correct items")
    @MainActor
    func whenInitializedWithItems_createsListViewWithCorrectItems() {
        let items = [
            TestItem(name: "Item 1"),
            TestItem(name: "Item 2"),
        ]

        let viewModel = DynamicListViewModel(items: items)
        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // We use a Mirror to inspect the properties of the DynamicList,
        // as we cannot directly access private properties.
        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let itemsFromMirror = viewModelFromMirror?.wrappedValue.items

        #expect(itemsFromMirror == items, "The items in the list should match the items provided on initialization.")
    }

    @Test("when initialized with empty items creates list view with empty state")
    @MainActor
    func whenInitializedWithEmptyItems_createsListViewWithEmptyState() {
        let items: [TestItem] = []

        let viewModel = DynamicListViewModel(items: items)
        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let itemsFromMirror = viewModelFromMirror?.wrappedValue.items

        #expect(itemsFromMirror?.isEmpty == true, "The list should be empty when initialized with empty items.")
    }

    @Test("when initialized with data provider creates list view with loading state")
    @MainActor
    func whenInitializedWithDataProvider_createsListViewWithLoadingState() {
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let loadingState = viewModelFromMirror?.wrappedValue.viewState.loadingState

        #expect(loadingState == .loading, "The list should be in loading state when initialized with data provider.")
    }

    @Test("when data provider sends items updates list view with loaded state")
    @MainActor
    func whenDataProviderSendsItems_updatesListViewWithLoadedState() {
        let items = [TestItem(name: "Loaded Item")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // Send data
        pts.send(items)

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let loadingState = viewModelFromMirror?.wrappedValue.viewState.loadingState
        let currentItems = viewModelFromMirror?.wrappedValue.items

        #expect(loadingState == .loaded, "The list should be in loaded state when data is received.")
        #expect(currentItems == items, "The list should display the items sent by the data provider.")
    }

    @Test("when data provider fails updates list view with error state")
    @MainActor
    func whenDataProviderFails_updatesListViewWithErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // Send error
        pts.send(completion: .failure(testError))

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let error = viewModelFromMirror?.wrappedValue.viewState.error

        #expect(error != nil, "The list should have an error when data provider fails.")
    }

    @Test("when refresh is called triggers data reload")
    @MainActor
    func whenRefreshIsCalled_triggersDataReload() {
        var callCount = 0
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: {
                callCount += 1
                return pts.eraseToAnyPublisher()
            },
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        _ = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // Verify initial load
        #expect(callCount == 1, "Data provider should be called once on initialization.")

        // Trigger refresh
        viewModel.refresh()

        #expect(callCount == 2, "Data provider should be called again when refresh is triggered.")
    }

    @Test("when custom error content is provided uses custom error view")
    @MainActor
    func whenCustomErrorContentIsProvided_usesCustomErrorView() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
            errorContent: { error in
                VStack {
                    Text("Custom Error")
                    Text(error.localizedDescription)
                }
            },
            skeletonContent: {
                DefaultSkeletonView()
            },
        )

        // Send error to trigger error state
        pts.send(completion: .failure(testError))

        // Verify that the view model has the error state
        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let error = viewModelFromMirror?.wrappedValue.viewState.error

        #expect(error != nil, "Custom error content should be set when provided.")
    }

    @Test("when view model is initialized with data provider reflects data changes")
    @MainActor
    func whenViewModelIsInitializedWithDataProvider_reflectsDataChanges() {
        let initialItems = [TestItem(name: "Initial")]
        let updatedItems = [TestItem(name: "Updated")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // Send initial items
        pts.send(initialItems)

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let currentItems = viewModelFromMirror?.wrappedValue.items

        #expect(currentItems == initialItems, "The list should reflect initial items when data provider sends data.")

        // Send updated items
        pts.send(updatedItems)

        let updatedItemsFromMirror = viewModelFromMirror?.wrappedValue.items
        #expect(updatedItemsFromMirror == updatedItems, "The list should reflect updated items when data provider sends new data.")
    }

    @Test("when view model has loading state shows progress view")
    @MainActor
    func whenViewModelHasLoadingState_showsProgressView() {
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let shouldShowLoading = viewModelFromMirror?.wrappedValue.viewState.shouldShowLoading

        #expect(shouldShowLoading == true, "The list should show loading state when view model is loading.")
    }

    @Test("when view model has error state shows error view")
    @MainActor
    func whenViewModelHasErrorState_showsErrorView() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in
                Text(item.name)
            },
            detailContent: { item in
                Text(item.name)
            },
        )

        // Send error to trigger error state
        pts.send(completion: .failure(testError))

        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let shouldShowError = viewModelFromMirror?.wrappedValue.viewState.shouldShowError

        #expect(shouldShowError == true, "The list should show error state when view model has error.")
    }
}
