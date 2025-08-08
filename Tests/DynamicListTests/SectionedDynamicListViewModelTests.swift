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

    @Test("init displays correct sections with provided sections")
    func init_displaysCorrectSectionsWithProvidedSections() {
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

    @Test("init displays empty state without sections")
    func init_displaysEmptyStateWithoutSections() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        #expect(viewModel.viewState.sections.isEmpty)
        #expect(viewModel.viewState.loadingState == .idle)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowError)
    }

    @Test("viewState provides correct convenience properties on idle state")
    func viewState_providesCorrectConveniencePropertiesOnIdleState() {
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

    @Test("init starts loading and displays data with data provider")
    func init_startsLoadingAndDisplaysDataWithDataProvider() {
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
        viewModel.loadData()
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(expectedArrays)
        #expect(viewModel.viewState.loadingState == .loaded)
        #expect(viewModel.viewState.sections.count == 2)
        #expect(viewModel.viewState.sections[0].items.count == 1)
        #expect(viewModel.viewState.sections[1].items.count == 1)
    }

    @Test("init displays error state on data provider failure")
    func init_displaysErrorStateOnDataProviderFailure() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()
        #expect(viewModel.viewState.loadingState == .loading)

        pts.send(completion: .failure(testError))
        #expect(viewModel.viewState.loadingState == .error(testError))
    }

    // MARK: - Data Loading Tests

    @Test("loadItems changes data provider")
    func loadItems_changesDataProvider() {
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

    @Test("refresh loads data from provider")
    func refresh_loadsDataFromProvider() {
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

    @Test("refresh uses new provider after loadItems")
    func refresh_usesNewProviderAfterLoadItems() {
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

    @Test("updateSections updates sections directly")
    func updateSections_updatesSectionsDirectly() {
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

    @Test("updateSections creates sections correctly with arrays")
    func updateSections_createsSectionsCorrectlyWithArrays() {
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

    @Test("updateSections creates sections with nil titles when arrays and nil titles provided")
    func updateSections_createsSectionsWithNilTitlesWhenArraysAndNilTitlesProvided() {
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

    @Test("updateSections creates empty sections with arrays without titles")
    func updateSections_createsEmptySectionsWithArraysWithoutTitles() {
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

    @Test("setSearchConfiguration stores configuration correctly")
    func setSearchConfiguration_storesConfigurationCorrectly() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<TestItem>.enabled(
            prompt: "Search items...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        #expect(viewModel.searchConfiguration != nil)
    }

    @Test("setSearchConfiguration clears configuration when set to nil")
    func setSearchConfiguration_clearsConfigurationWhenSetToNil() {
        let viewModel = SectionedDynamicListViewModel<TestItem>(
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<TestItem>.enabled(
            prompt: "Search items...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        #expect(viewModel.searchConfiguration != nil)

        viewModel.setSearchConfiguration(nil)
        #expect(viewModel.searchConfiguration == nil)
    }

    // MARK: - Loading State Tests

    @Test("viewState provides correct convenience properties on loading state")
    func viewState_providesCorrectConveniencePropertiesOnLoadingState() {
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()

        #expect(viewModel.viewState.loadingState == .loading)
        #expect(viewModel.viewState.isLoading)
        #expect(viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowList)
        #expect(!viewModel.viewState.shouldShowError)
    }

    @Test("viewState provides correct convenience properties on loaded state")
    func viewState_providesCorrectConveniencePropertiesOnLoadedState() {
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

    @Test("viewState provides correct convenience properties on error state")
    func viewState_providesCorrectConveniencePropertiesOnErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[[TestItem]], Error>()

        let viewModel = SectionedDynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.loadData()

        pts.send(completion: .failure(testError))

        #expect(viewModel.viewState.loadingState == .error(testError))
        #expect(!viewModel.viewState.isLoading)
        #expect(!viewModel.viewState.shouldShowLoading)
        #expect(!viewModel.viewState.shouldShowList)
        #expect(viewModel.viewState.shouldShowError)
    }

    // MARK: - Data Provider Context Tests

    @Test("refresh uses updated context when data provider captures context")
    func refresh_usesUpdatedContextWhenDataProviderCapturesContext() {
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
        viewModel.loadData()

        // Initial load
        #expect(viewModel.viewState.sections[0].items.first?.name == "initial")

        // Update context and refresh
        context = "updated"
        viewModel.refresh()
        #expect(viewModel.viewState.sections[0].items.first?.name == "updated")
    }
}
