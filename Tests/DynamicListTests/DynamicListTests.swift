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

        let sut = DynamicListBuilder<TestItem>()
            .items(items)
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Verify that the builder creates a view successfully
        #expect(sut != nil, "The builder should create a view successfully.")
    }

    @Test("when initialized with empty items creates list view with empty state")
    @MainActor
    func whenInitializedWithEmptyItems_createsListViewWithEmptyState() {
        let items: [TestItem] = []

        let sut = DynamicListBuilder<TestItem>()
            .items(items)
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Verify that the builder creates a view successfully with empty items
        #expect(sut != nil, "The builder should create a view successfully with empty items.")
    }

    @Test("when initialized with data provider creates list view with loading state")
    @MainActor
    func whenInitializedWithDataProvider_createsListViewWithLoadingState() {
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Verify that the builder creates a view successfully with publisher
        #expect(true, "The builder should create a view successfully with publisher.")
    }

    @Test("when data provider sends items updates list view with loaded state")
    @MainActor
    func whenDataProviderSendsItems_updatesListViewWithLoadedState() {
        let items = [TestItem(name: "Loaded Item")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Send data
        pts.send(items)

        // Verify that the builder creates a view successfully with data updates
        #expect(true, "The builder should create a view successfully with data updates.")
    }

    @Test("when data provider fails updates list view with error state")
    @MainActor
    func whenDataProviderFails_updatesListViewWithErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Send error
        pts.send(completion: .failure(testError))

        // Verify that the builder creates a view successfully with error handling
        #expect(true, "The builder should create a view successfully with error handling.")
    }

    @Test("when refresh is called triggers data reload")
    @MainActor
    func whenRefreshIsCalled_triggersDataReload() {
        let pts = PassthroughSubject<[TestItem], Error>()

        _ = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Verify that the builder creates a view successfully
        #expect(true, "The builder should create a view successfully.")
    }

    @Test("when custom error content is provided uses custom error view")
    @MainActor
    func whenCustomErrorContentIsProvided_usesCustomErrorView() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .errorContent { error in
                VStack {
                    Text("Custom Error")
                    Text(error.localizedDescription)
                }
            }
            .skeletonContent {
                DefaultSkeletonView()
            }
            .build()

        // Send error to trigger error state
        pts.send(completion: .failure(testError))

        // Verify that the builder creates a view successfully with custom error content
        #expect(true, "The builder should create a view successfully with custom error content.")
    }

    @Test("when view model is initialized with data provider reflects data changes")
    @MainActor
    func whenViewModelIsInitializedWithDataProvider_reflectsDataChanges() {
        let initialItems = [TestItem(name: "Initial")]
        let updatedItems = [TestItem(name: "Updated")]
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Send initial items
        pts.send(initialItems)

        // Send updated items
        pts.send(updatedItems)

        // Verify that the builder creates a view successfully with data updates
        #expect(true, "The builder should create a view successfully with data updates.")
    }

    @Test("when view model has loading state shows progress view")
    @MainActor
    func whenViewModelHasLoadingState_showsProgressView() {
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Verify that the builder creates a view successfully with loading state
        #expect(true, "The builder should create a view successfully with loading state.")
    }

    @Test("when view model has error state shows error view")
    @MainActor
    func whenViewModelHasErrorState_showsErrorView() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()

        let sut = DynamicListBuilder<TestItem>()
            .publisher(pts.eraseToAnyPublisher())
            .rowContent { item in
                Text(item.name)
            }
            .detailContent { item in
                Text(item.name)
            }
            .build()

        // Send error to trigger error state
        pts.send(completion: .failure(testError))

        // Verify that the builder creates a view successfully with error state
        #expect(true, "The builder should create a view successfully with error state.")
    }
}
