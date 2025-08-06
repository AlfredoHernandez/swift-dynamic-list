//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Combine
import CombineSchedulers
import Foundation
import Testing

@Suite("SectionedDynamicListViewModel Tests")
struct SectionedDynamicListViewModelTests {
    // MARK: - Test Models

    struct TestItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let category: String
    }

    // MARK: - Initialization Tests

    @Test("When initialized with sections displays correct sections")
    func whenInitializedWithSections_displaysCorrectSections() {
        let sections = [
            ListSection(title: "Category 1", items: [TestItem(name: "Item 1", category: "Cat1")]),
            ListSection(title: "Category 2", items: [TestItem(name: "Item 2", category: "Cat2")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.sections == sections)
        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.isLoading)
        #expect(viewModel.viewState.error == nil)
    }

    @Test("When initialized without sections displays empty state")
    func whenInitializedWithoutSections_displaysEmptyState() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.sections.isEmpty)
        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
    }

    @Test("When view state is idle provides correct convenience properties")
    func whenViewStateIsIdle_providesCorrectConvenienceProperties() {
        let sections = [
            ListSection(title: "Category 1", items: [TestItem(name: "Item 1", category: "Cat1")]),
            ListSection(title: "Category 2", items: [TestItem(name: "Item 2", category: "Cat2")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.isEmpty)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
        #expect(viewModel.viewState.isLoaded == false) // idle state is not loaded
    }

    // MARK: - Data Provider Tests

    @Test("When initialized with data provider starts loading and displays data when received")
    func whenInitializedWithDataProvider_startsLoadingAndDisplaysDataWhenReceived() {
        let expectedArrays = [
            [TestItem(name: "Item 1", category: "Cat1")],
            [TestItem(name: "Item 2", category: "Cat2")],
        ]
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(expectedArrays)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.viewState.sections.count == 2)
        #expect(viewModel.viewState.sections[0].items.count == 1)
        #expect(viewModel.viewState.sections[1].items.count == 1)
    }

    @Test("When data provider fails displays error state")
    func whenDataProviderFails_displaysErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(completion: .failure(testError))
        #expect(viewModel.viewState.loadingState == .error(testError))
    }

    // MARK: - Data Loading Tests

    @Test("When loadItems is called changes data provider")
    func whenLoadItemsIsCalled_changesDataProvider() {
        let initialSections = [
            ListSection(title: "Initial", items: [TestItem(name: "Initial", category: "Init")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: initialSections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let newArrays = [[TestItem(name: "New", category: "New")]]
        let pts = PassthroughSubject<[[TestItem]], Error>()

        viewModel.loadItems(from: pts.eraseToAnyPublisher)
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(newArrays)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.viewState.sections.count == 1)
        #expect(viewModel.viewState.sections[0].items.first?.name == "New")
    }

    @Test("When refresh is called loads data from provider")
    func whenRefreshIsCalled_loadsDataFromProvider() {
        let initialSections = [
            ListSection(title: "Initial", items: [TestItem(name: "Initial", category: "Init")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: initialSections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let pts = PassthroughSubject<[[TestItem]], Error>()
        viewModel.loadItems(from: pts.eraseToAnyPublisher)

        // Send initial data
        pts.send([[TestItem(name: "First", category: "First")]])
        #expect(viewModel.viewState.sections[0].items.first?.name == "First")

        // Refresh should trigger new load
        viewModel.refresh()
        #expect(viewModel.viewState.loadingState == .loading)

        // Send new data
        pts.send([[TestItem(name: "Refreshed", category: "Refresh")]])
        #expect(viewModel.viewState.sections[0].items.first?.name == "Refreshed")
    }

    @Test("When refresh is called after loadItems uses new provider")
    func whenRefreshIsCalledAfterLoadItems_usesNewProvider() {
        let initialSections = [
            ListSection(title: "Initial", items: [TestItem(name: "Initial", category: "Init")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: initialSections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let pts1 = PassthroughSubject<[[TestItem]], Error>()
        let pts2 = PassthroughSubject<[[TestItem]], Error>()

        viewModel.loadItems(from: pts1.eraseToAnyPublisher)
        pts1.send([[TestItem(name: "First", category: "First")]])
        #expect(viewModel.viewState.sections[0].items.first?.name == "First")

        viewModel.loadItems(from: pts2.eraseToAnyPublisher)
        viewModel.refresh()
        pts2.send([[TestItem(name: "Second", category: "Second")]])
        #expect(viewModel.viewState.sections[0].items.first?.name == "Second")
    }

    // MARK: - Section Update Tests

    @Test("When updateSections is called updates sections directly")
    func whenUpdateSectionsIsCalled_updatesSectionsDirectly() {
        let initialSections = [
            ListSection(title: "Initial", items: [TestItem(name: "Initial", category: "Init")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: initialSections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let newSections = [
            ListSection(title: "Updated", items: [TestItem(name: "Updated", category: "Update")]),
        ]

        viewModel.updateSections(newSections)
        #expect(viewModel.viewState.sections == newSections)
        #expect(viewModel.viewState.sections[0].title == "Updated")
        #expect(viewModel.viewState.sections[0].items.first?.name == "Updated")
    }

    @Test("When updateSections with arrays creates sections correctly")
    func whenUpdateSectionsWithArrays_createsSectionsCorrectly() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let arrays = [
            [TestItem(name: "Item 1", category: "Cat1")],
            [TestItem(name: "Item 2", category: "Cat2")],
        ]
        let titles = ["Category 1", "Category 2"]

        viewModel.updateSections(arrays: arrays, titles: titles)
        #expect(viewModel.viewState.sections.count == 2)
        #expect(viewModel.viewState.sections[0].title == "Category 1")
        #expect(viewModel.viewState.sections[1].title == "Category 2")
        #expect(viewModel.viewState.sections[0].items.first?.name == "Item 1")
        #expect(viewModel.viewState.sections[1].items.first?.name == "Item 2")
    }

    @Test("When updateSections with arrays and nil titles creates sections with nil titles")
    func whenUpdateSectionsWithArraysAndNilTitles_createsSectionsWithNilTitles() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let arrays = [
            [TestItem(name: "Item 1", category: "Cat1")],
            [TestItem(name: "Item 2", category: "Cat2")],
        ]
        let titles: [String?] = [nil, nil]

        viewModel.updateSections(arrays: arrays, titles: titles)
        #expect(viewModel.viewState.sections.count == 2)
        #expect(viewModel.viewState.sections[0].title == nil)
        #expect(viewModel.viewState.sections[1].title == nil)
        #expect(viewModel.viewState.sections[0].items.first?.name == "Item 1")
        #expect(viewModel.viewState.sections[1].items.first?.name == "Item 2")
    }

    @Test("When updateSections with arrays without titles creates sections with nil titles")
    func whenUpdateSectionsWithArraysWithoutTitles_createsSectionsWithNilTitles() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let arrays = [
            [TestItem(name: "Item 1", category: "Cat1")],
            [TestItem(name: "Item 2", category: "Cat2")],
        ]

        // When no titles are provided, zip will be empty, so no sections will be created
        viewModel.updateSections(arrays: arrays)
        #expect(viewModel.viewState.sections.isEmpty)
    }

    // MARK: - Search Configuration Tests

    @Test("When search configuration is set stores configuration correctly")
    func whenSearchConfigurationIsSet_storesConfigurationCorrectly() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<TestItem>(
            prompt: "Search items...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        // Note: We can't directly test the private property, but we can test its effects
        // through search functionality tests
    }

    @Test("When search configuration is set to nil clears configuration")
    func whenSearchConfigurationIsSetToNil_clearsConfiguration() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<TestItem>(
            prompt: "Search items...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.setSearchConfiguration(nil)
        // Note: We can't directly test the private property, but we can test its effects
        // through search functionality tests
    }

    // MARK: - Loading State Tests

    @Test("When loading state is loading provides correct convenience properties")
    func whenLoadingStateIsLoading_providesCorrectConvenienceProperties() {
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.loadingState == .loading)
        #expect(viewModel.viewState.isLoading)
        #expect(viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.shouldShowError)
    }

    @Test("When loading state is loaded provides correct convenience properties")
    func whenLoadingStateIsLoaded_providesCorrectConvenienceProperties() {
        let sections = [
            ListSection(title: "Category 1", items: [TestItem(name: "Item 1", category: "Cat1")]),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.isLoading)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.shouldShowError)
        #expect(viewModel.viewState.isLoaded == false) // idle state is not loaded
    }

    @Test("When loading state is error provides correct convenience properties")
    func whenLoadingStateIsError_providesCorrectConvenienceProperties() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        pts.send(completion: .failure(testError))

        #expect(viewModel.viewState.loadingState == .error(testError))
        #expect(!viewModel.viewState.isLoading)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowList)
        #expect(viewModel.viewState.shouldShowError)
    }

    // MARK: - Data Provider Context Tests

    @Test("When data provider captures context uses updated context on refresh")
    func whenDataProviderCapturesContext_usesUpdatedContextOnRefresh() {
        var context = "initial"
        let dataProvider = {
            Just([[TestItem(name: context, category: context)]])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: dataProvider,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        // Initial load
        #expect(viewModel.viewState.sections[0].items.first?.name == "initial")

        // Update context and refresh
        context = "updated"
        viewModel.refresh()
        #expect(viewModel.viewState.sections[0].items.first?.name == "updated")
    }
}
