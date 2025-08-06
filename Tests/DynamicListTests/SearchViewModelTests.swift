//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import SwiftUI
import Testing

@Suite
struct SearchViewModelTests {
    // MARK: - Test Models

    struct SearchableUser: Identifiable, Hashable, Searchable {
        let id = UUID()
        let name: String
        let email: String
        let role: String

        var searchKeys: [String] {
            [name, email, role]
        }
    }

    // MARK: - DynamicListViewModel Search Tests

    @Test("when search text is empty returns all items")
    func whenSearchTextIsEmpty_returnsAllItems() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(items: users)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = ""

        #expect(viewModel.filteredItemsList.count == 2)
        #expect(viewModel.filteredItemsList.contains(where: { $0.name == "Ana" }))
        #expect(viewModel.filteredItemsList.contains(where: { $0.name == "Bob" }))
    }

    @Test("when search text matches name filters correctly")
    func whenSearchTextMatchesName_filtersCorrectly() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Ana")
    }

    @Test("when search text matches email filters correctly")
    func whenSearchTextMatchesEmail_filtersCorrectly() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "bob@test.com"

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Bob")
    }

    @Test("when using custom predicate filters correctly")
    func whenUsingCustomPredicate_filtersCorrectly() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            predicate: { user, query in
                user.role.lowercased().contains(query.lowercased())
            },
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "admin"

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.role == "Admin")
    }

    @Test("when no search configuration uses fallback filtering")
    func whenNoSearchConfiguration_usesFallbackFiltering() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        viewModel.searchText = "Ana"

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Ana")
    }

    // MARK: - SectionedDynamicListViewModel Search Tests

    @Test("when search text is empty returns all sections")
    func whenSearchTextIsEmpty_returnsAllSections() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = ""

        #expect(viewModel.filteredSectionsList.count == 2)
        #expect(viewModel.filteredSectionsList[0].title == "Admins")
        #expect(viewModel.filteredSectionsList[1].title == "Users")
    }

    @Test("when search text matches items in one section filters correctly")
    func whenSearchTextMatchesItemsInOneSection_filtersCorrectly() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].title == "Admins")
        #expect(viewModel.filteredSectionsList[0].items.count == 1)
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")
    }

    @Test("when search text matches items in multiple sections shows all matching sections")
    func whenSearchTextMatchesItemsInMultipleSections_showsAllMatchingSections() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Alice", email: "alice@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "a"

        #expect(viewModel.filteredSectionsList.count == 2)
        #expect(viewModel.filteredSectionsList[0].title == "Admins")
        #expect(viewModel.filteredSectionsList[1].title == "Users")
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")
        #expect(viewModel.filteredSectionsList[1].items.first?.name == "Alice")
    }

    @Test("when search text matches no items returns empty sections")
    func whenSearchTextMatchesNoItems_returnsEmptySections() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "xyz"

        #expect(viewModel.filteredSectionsList.isEmpty)
    }

    @Test("when using exact match strategy filters correctly")
    func whenUsingExactMatchStrategy_filtersCorrectly() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: ExactMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")

        viewModel.searchText = "an"
        #expect(viewModel.filteredSectionsList.isEmpty)
    }

    // MARK: - Search State Tests

    @Test("when search text is updated in view model reflects in searchText property")
    func whenSearchTextIsUpdatedInViewModel_reflectsInSearchTextProperty() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        // Verify initial empty state
        #expect(viewModel.searchText.isEmpty)

        // Set search text to "Ana"
        viewModel.searchText = "Ana"
        #expect(viewModel.searchText == "Ana")

        // Change search text to "Bob"
        viewModel.searchText = "Bob"
        #expect(viewModel.searchText == "Bob")

        // Clear search text
        viewModel.searchText = ""
        #expect(viewModel.searchText.isEmpty)
    }

    @Test("when search text is updated directly triggers automatic filtering")
    func whenSearchTextIsUpdatedDirectly_triggersAutomaticFiltering() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )
        viewModel.setSearchConfiguration(searchConfig)

        // Verify all items are shown initially
        #expect(viewModel.filteredItemsList.count == 2)

        // Search for "Ana" - should filter to one item
        viewModel.searchText = "Ana"
        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Ana")

        // Search for "Bob" - should filter to one item
        viewModel.searchText = "Bob"
        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Bob")

        // Clear search - should show all items again
        viewModel.searchText = ""
        #expect(viewModel.filteredItemsList.count == 2)
    }

    @Test("when search text is updated directly in sectioned view model triggers automatic filtering")
    func whenSearchTextIsUpdatedDirectlyInSectionedViewModel_triggersAutomaticFiltering() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )
        viewModel.setSearchConfiguration(searchConfig)

        // Verify all sections are shown initially
        #expect(viewModel.filteredSectionsList.count == 2)

        // Search for "Ana" - should filter to one section
        viewModel.searchText = "Ana"
        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].title == "Admins")
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")

        // Search for "Bob" - should filter to one section
        viewModel.searchText = "Bob"
        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].title == "Users")
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Bob")

        // Clear search - should show all sections again
        viewModel.searchText = ""
        #expect(viewModel.filteredSectionsList.count == 2)
    }

    @Test("when search text is updated in sectioned view model reflects in searchText property")
    func whenSearchTextIsUpdatedInSectionedViewModel_reflectsInSearchTextProperty() {
        let sections = [
            ListSection(
                title: "Admins",
                items: [SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin")],
            ),
            ListSection(
                title: "Users",
                items: [SearchableUser(name: "Bob", email: "bob@test.com", role: "User")],
            ),
        ]

        let viewModel = SectionedDynamicListViewModel(
            sections: sections,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        // Verify initial empty state
        #expect(viewModel.searchText.isEmpty)

        // Set search text to "Ana"
        viewModel.searchText = "Ana"
        #expect(viewModel.searchText == "Ana")

        // Change search text to "Bob"
        viewModel.searchText = "Bob"
        #expect(viewModel.searchText == "Bob")

        // Clear search text
        viewModel.searchText = ""
        #expect(viewModel.searchText.isEmpty)
    }
}
