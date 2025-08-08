//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Advanced Features Example

#Preview("Advanced Features - Optional Details & Default Views") {
    TabView {
        // Optional detail content
        SectionedDynamicListBuilder<User>()
            .title("Users - Optional Details")
            .groupedItems([
                users.filter(\.isActive),
                users.filter { !$0.isActive },
            ], titles: ["Active Users", "Inactive Users"])
            .rowContent { user in
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.name).font(.headline)
                        Text(user.role).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    if user.isActive {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                    }
                }
            }
            .optionalDetailContent { user in
                // Only show detail view for active users
                if user.isActive {
                    AnyView(
                        VStack(spacing: 16) {
                            Text(user.name).font(.title).fontWeight(.bold)
                            Text(user.role).font(.headline).foregroundColor(.secondary)
                            if user.role == "Admin" {
                                Text("This user has administrator permissions")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("User Detail"),
                    )
                } else {
                    nil
                }
            }
            .build()
            .tabItem {
                Image(systemName: "person.crop.circle.badge.questionmark")
                Text("Optional")
            }

        // Default views showcase
        NavigationStack {
            List {
                Section("Default Row Views") {
                    DefaultRowView(item: users[0])
                    DefaultRowView(item: products[0])
                }

                Section("Default Detail Views") {
                    NavigationLink("User Detail") {
                        DefaultDetailView(item: users[0])
                            .navigationTitle("User Detail")
                    }
                    NavigationLink("Product Detail") {
                        DefaultDetailView(item: products[0])
                            .navigationTitle("Product Detail")
                    }
                }

                Section("Loading & Error States") {
                    NavigationLink("Skeleton Loading") {
                        DefaultSkeletonView()
                            .navigationTitle("Loading...")
                    }
                    NavigationLink("Error State") {
                        DefaultErrorView(error: LoadError.networkError)
                            .navigationTitle("Error")
                    }
                }
            }
            .navigationTitle("Default Views")
        }
        .tabItem {
            Image(systemName: "rectangle.stack")
            Text("Defaults")
        }
    }
}
