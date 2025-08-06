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

#Preview("List with navigation and custom actions") {
    NavigationStack {
        DynamicListBuilder.simple(
            title: "Users",
            items: User.sampleUsers,
            rowContent: { user in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 25, height: 25)

                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.body)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { print("Tapped on: \(user.name)") }) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            },
            detailContent: { user in
                Text("Detail view for \(user.name)")
            },
        )
    }
}

#Preview("List without navigation and custom actions") {
    DynamicListBuilder<User>()
        .items(User.sampleUsers)
        .rowContent { user in
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 25, height: 25)

                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.body)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { print("Tapped on: \(user.name)") }) {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .title("List without Navigation")
        .build()
}
