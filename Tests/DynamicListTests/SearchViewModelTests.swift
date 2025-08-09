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

    @Test("DynamicListViewModel returns all items on empty search text")
    func dynamicListViewModel_returnsAllItemsOnEmptySearchText() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(items: users)
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = ""

        #expect(viewModel.items.count == 2)
        #expect(viewModel.items.contains(where: { $0.name == "Ana" }))
        #expect(viewModel.items.contains(where: { $0.name == "Bob" }))
    }

    @Test("DynamicListViewModel filters correctly when search text matches name")
    func dynamicListViewModel_filtersCorrectlyWhenSearchTextMatchesName() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Ana")
    }

    @Test("DynamicListViewModel filters correctly when search text matches email")
    func dynamicListViewModel_filtersCorrectlyWhenSearchTextMatchesEmail() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "bob@test.com"

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Bob")
    }

    @Test("DynamicListViewModel filters correctly with custom predicate")
    func dynamicListViewModel_filtersCorrectlyWithCustomPredicate() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            predicate: { user, query in
                user.role.lowercased().contains(query.lowercased())
            },
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "admin"

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.role == "Admin")
    }

    @Test("DynamicListViewModel uses fallback filtering without search configuration")
    func dynamicListViewModel_usesFallbackFilteringWithoutSearchConfiguration() {
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

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Ana")
    }

    // MARK: - SectionedDynamicListViewModel Search Tests

    @Test("SectionedDynamicListViewModel returns all sections on empty search text")
    func sectionedDynamicListViewModel_returnsAllSectionsOnEmptySearchText() {
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
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = ""

        #expect(viewModel.sections.count == 2)
        #expect(viewModel.sections[0].title == "Admins")
        #expect(viewModel.sections[1].title == "Users")
    }

    @Test("SectionedDynamicListViewModel filters correctly when search text matches items in one section")
    func sectionedDynamicListViewModel_filtersCorrectlyWhenSearchTextMatchesItemsInOneSection() {
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
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections[0].title == "Admins")
        #expect(viewModel.sections[0].items.count == 1)
        #expect(viewModel.sections[0].items.first?.name == "Ana")
    }

    @Test("SectionedDynamicListViewModel shows all matching sections when search text matches items in multiple sections")
    func sectionedDynamicListViewModel_showsAllMatchingSectionsWhenSearchTextMatchesItemsInMultipleSections() {
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
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "a"

        #expect(viewModel.sections.count == 2)
        #expect(viewModel.sections[0].title == "Admins")
        #expect(viewModel.sections[1].title == "Users")
        #expect(viewModel.sections[0].items.first?.name == "Ana")
        #expect(viewModel.sections[1].items.first?.name == "Alice")
    }

    @Test("SectionedDynamicListViewModel returns empty sections when search text matches no items")
    func sectionedDynamicListViewModel_returnsEmptySectionsWhenSearchTextMatchesNoItems() {
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
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "xyz"

        #expect(viewModel.sections.isEmpty)
    }

    @Test("SectionedDynamicListViewModel filters correctly with exact match strategy")
    func sectionedDynamicListViewModel_filtersCorrectlyWithExactMatchStrategy() {
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
        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: ExactMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.searchText = "Ana"

        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections[0].items.first?.name == "Ana")

        viewModel.searchText = "an"
        #expect(viewModel.sections.isEmpty)
    }

    // MARK: - Search State Tests

    @Test("DynamicListViewModel searchText property reflects updates")
    func dynamicListViewModel_searchTextPropertyReflectsUpdates() {
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

    @Test("DynamicListViewModel triggers automatic filtering on direct search text update")
    func dynamicListViewModel_triggersAutomaticFilteringOnDirectSearchTextUpdate() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(
            items: users,
            scheduler: .immediate,
            ioScheduler: .immediate,
        )

        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )
        viewModel.setSearchConfiguration(searchConfig)

        // Verify all items are shown initially
        #expect(viewModel.items.count == 2)

        // Search for "Ana" - should filter to one item
        viewModel.searchText = "Ana"
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Ana")

        // Search for "Bob" - should filter to one item
        viewModel.searchText = "Bob"
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Bob")

        // Clear search - should show all items again
        viewModel.searchText = ""
        #expect(viewModel.items.count == 2)
    }

    @Test("SectionedDynamicListViewModel triggers automatic filtering on direct search text update")
    func sectionedDynamicListViewModel_triggersAutomaticFilteringOnDirectSearchTextUpdate() {
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

        let searchConfig = SearchConfiguration<SearchableUser>.enabled(
            prompt: "Search...",
            strategy: PartialMatchStrategy(),
        )
        viewModel.setSearchConfiguration(searchConfig)

        // Verify all sections are shown initially
        #expect(viewModel.sections.count == 2)

        // Search for "Ana" - should filter to one section
        viewModel.searchText = "Ana"
        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections[0].title == "Admins")
        #expect(viewModel.sections[0].items.first?.name == "Ana")

        // Search for "Bob" - should filter to one section
        viewModel.searchText = "Bob"
        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections[0].title == "Users")
        #expect(viewModel.sections[0].items.first?.name == "Bob")

        // Clear search - should show all sections again
        viewModel.searchText = ""
        #expect(viewModel.sections.count == 2)
    }

    @Test("SectionedDynamicListViewModel searchText property reflects updates")
    func sectionedDynamicListViewModel_searchTextPropertyReflectsUpdates() {
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
