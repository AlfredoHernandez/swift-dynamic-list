//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Example demonstrating how to enable search functionality in DynamicList.
///
/// This example shows the difference between:
/// - Default behavior (search disabled)
/// - Explicitly enabled search
struct SearchEnabledExample: View {
    private let users = [
        SearchableUser(name: "Ana García", email: "ana@example.com", role: "Admin"),
        SearchableUser(name: "Bob Smith", email: "bob@example.com", role: "User"),
        SearchableUser(name: "Carlos López", email: "carlos@example.com", role: "Manager"),
        SearchableUser(name: "Diana Chen", email: "diana@example.com", role: "User"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Without search (default behavior)") {
                    NavigationLink("List without search") {
                        buildListWithoutSearch()
                    }
                }

                Section("With search enabled") {
                    NavigationLink("List with basic search") {
                        buildListWithBasicSearch()
                    }

                    NavigationLink("List with custom search") {
                        buildListWithCustomSearch()
                    }
                }

                Section("Sectioned list with search") {
                    NavigationLink("Sectioned list with search") {
                        buildSectionedListWithSearch()
                    }
                }
            }
            .navigationTitle("Search Examples")
        }
    }

    @ViewBuilder
    private func buildListWithoutSearch() -> some View {
        DynamicListBuilder<SearchableUser>()
            .items(users)
            .rowContent { user in
                AnyView(
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    },
                )
            }
            .build()
    }

    @ViewBuilder
    private func buildListWithBasicSearch() -> some View {
        DynamicListBuilder<SearchableUser>()
            .items(users)
            .searchable(prompt: "Search users...")
            .rowContent { user in
                AnyView(
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    },
                )
            }
            .build()
    }

    @ViewBuilder
    private func buildListWithCustomSearch() -> some View {
        DynamicListBuilder<SearchableUser>()
            .items(users)
            .searchable(
                prompt: "Search by name or role...",
                predicate: { user, query in
                    user.name.lowercased().contains(query.lowercased()) ||
                        user.role.lowercased().contains(query.lowercased())
                },
            )
            .rowContent { user in
                AnyView(
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    },
                )
            }
            .build()
    }

    @ViewBuilder
    private func buildSectionedListWithSearch() -> some View {
        let sections = [
            ListSection(
                title: "Administrators",
                items: users.filter { $0.role == "Admin" },
            ),
            ListSection(
                title: "Users",
                items: users.filter { $0.role == "User" },
            ),
            ListSection(
                title: "Managers",
                items: users.filter { $0.role == "Manager" },
            ),
        ]

        SectionedDynamicListBuilder<SearchableUser>()
            .sections(sections)
            .searchable(prompt: "Search across all sections...")
            .rowContent { user in
                AnyView(
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text("\(user.role) • \(user.email)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    },
                )
            }
            .build()
    }
}

// MARK: - SearchableUser Model

private struct SearchableUser: Identifiable, Hashable, Searchable {
    let id = UUID()
    let name: String
    let email: String
    let role: String

    var searchKeys: [String] {
        [name, email, role]
    }
}

#Preview {
    SearchEnabledExample()
}
