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
                Section("Sin búsqueda (comportamiento por defecto)") {
                    NavigationLink("Lista sin búsqueda") {
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
                }

                Section("Con búsqueda habilitada") {
                    NavigationLink("Lista con búsqueda") {
                        DynamicListBuilder<SearchableUser>()
                            .items(users)
                            .searchable(prompt: "Buscar usuarios...", placement: .navigationBarDrawer(displayMode: .automatic))
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

                    NavigationLink("Lista con búsqueda personalizada") {
                        DynamicListBuilder<SearchableUser>()
                            .items(users)
                            .searchable(
                                prompt: "Buscar por nombre o rol...",
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
                }

                Section("Lista seccionada con búsqueda") {
                    NavigationLink("Lista seccionada con búsqueda") {
                        let sections = [
                            ListSection(
                                title: "Administradores",
                                items: users.filter { $0.role == "Admin" },
                            ),
                            ListSection(
                                title: "Usuarios",
                                items: users.filter { $0.role == "User" },
                            ),
                            ListSection(
                                title: "Gerentes",
                                items: users.filter { $0.role == "Manager" },
                            ),
                        ]

                        return SectionedDynamicListBuilder<SearchableUser>()
                            .sections(sections)
                            .searchable(prompt: "Buscar en todas las secciones...")
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
            }
            .navigationTitle("Ejemplos de Búsqueda")
        }
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
