//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

private struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String

    static let sampleUsers = [
        User(name: "Alice Johnson", email: "alice@example.com"),
        User(name: "Bob Smith", email: "bob@example.com"),
        User(name: "Carol Davis", email: "carol@example.com"),
        User(name: "David Wilson", email: "david@example.com"),
        User(name: "Eva Brown", email: "eva@example.com"),
        User(name: "Frank Miller", email: "frank@example.com"),
    ]
}

#Preview("Simple List with onTapRow") {
    DynamicListBuilder.simpleWithAction(
        items: User.sampleUsers,
        rowContent: { user in
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.body)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        },
        onTapRow: { user in
            print("Selected user: \(user.name)")
        },
    )
}

#Preview("Sectioned List with onTapRow") {
    SectionedDynamicListBuilder<User>()
        .sections([
            ListSection(title: "Active Users", items: User.sampleUsers.prefix(3).map(\.self)),
            ListSection(title: "Inactive Users", items: User.sampleUsers.dropFirst(3).map(\.self)),
        ])
        .rowContent { user in
            HStack {
                Circle()
                    .fill(user.email.contains("active") ? Color.green : Color.gray)
                    .frame(width: 25, height: 25)

                Text(user.name)
                    .font(.body)

                Spacer()

                Image(systemName: "hand.tap")
                    .foregroundColor(.blue)
            }
        }
        .onTapRow { user in
            print("Tapped on: \(user.name) (\(user.email))")
        }
        .build()
}
