//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Example demonstrating the optional detail content feature.
///
/// This example shows how to conditionally enable navigation for specific items
/// by returning `nil` from the detail content closure.
struct OptionalDetailContentExample: View {
    struct User: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let isActive: Bool
        let role: String
    }

    private let users = [
        [
            User(name: "Alice", isActive: true, role: "Admin"),
            User(name: "Bob", isActive: false, role: "User"),
        ],
        [
            User(name: "Charlie", isActive: true, role: "Moderator"),
            User(name: "Diana", isActive: false, role: "User"),
            User(name: "Eve", isActive: true, role: "Admin"),
        ],
    ]

    var body: some View {
        SectionedDynamicListBuilder<User>()
            .title("Users")
            .groupedItems(users, titles: ["First Section", "Second Section"])
            .rowContent { user in
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if user.isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .optionalDetailContent { user in
                // Only show detail view for active users
                if user.isActive {
                    AnyView(
                        VStack(spacing: 16) {
                            Text(user.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(user.role)
                                .font(.headline)
                                .foregroundColor(.secondary)

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
                    // Return nil for inactive users - no navigation will be shown
                    nil
                }
            }
            .build()
    }
}

#Preview {
    OptionalDetailContentExample()
}
