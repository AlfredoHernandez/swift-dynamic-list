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
        viewModel.updateSearchText("")

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

        let viewModel = DynamicListViewModel(items: users)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("Ana")

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Ana")
    }

    @Test("when search text matches email filters correctly")
    func whenSearchTextMatchesEmail_filtersCorrectly() {
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
        viewModel.updateSearchText("bob@test.com")

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.name == "Bob")
    }

    @Test("when using custom predicate filters correctly")
    func whenUsingCustomPredicate_filtersCorrectly() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(items: users)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            predicate: { user, query in
                user.role.lowercased().contains(query.lowercased())
            },
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("admin")

        #expect(viewModel.filteredItemsList.count == 1)
        #expect(viewModel.filteredItemsList.first?.role == "Admin")
    }

    @Test("when no search configuration uses fallback filtering")
    func whenNoSearchConfiguration_usesFallbackFiltering() {
        let users = [
            SearchableUser(name: "Ana", email: "ana@test.com", role: "Admin"),
            SearchableUser(name: "Bob", email: "bob@test.com", role: "User"),
        ]

        let viewModel = DynamicListViewModel(items: users)
        viewModel.updateSearchText("Ana")

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

        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("")

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

        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("Ana")

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

        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("a")

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

        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: PartialMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("xyz")

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

        let viewModel = SectionedDynamicListViewModel(sections: sections)
        let searchConfig = SearchConfiguration<SearchableUser>(
            prompt: "Buscar usuarios...",
            strategy: ExactMatchStrategy(),
        )

        viewModel.setSearchConfiguration(searchConfig)
        viewModel.updateSearchText("Ana")

        #expect(viewModel.filteredSectionsList.count == 1)
        #expect(viewModel.filteredSectionsList[0].items.first?.name == "Ana")

        viewModel.updateSearchText("an")
        #expect(viewModel.filteredSectionsList.isEmpty)
    }
}
