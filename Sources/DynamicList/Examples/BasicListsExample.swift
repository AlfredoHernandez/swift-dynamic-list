//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Basic Lists Example

#Preview("Basic Lists - Static Data") {
    TabView {
        // Simple list with static data
        DynamicListBuilder<Fruit>()
            .title("Fruits")
            .items(fruits)
            .searchable()
            .rowContent { fruit in
                HStack {
                    Text(fruit.symbol).font(.title2)
                    VStack(alignment: .leading) {
                        Text(fruit.name).font(.headline)
                        Text("Color: \(String(describing: fruit.color))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .detailContent { fruit in
                VStack(spacing: 20) {
                    Text(fruit.symbol).font(.system(size: 100))
                    Text(fruit.name).font(.largeTitle).bold()
                    Text("Color: \(String(describing: fruit.color))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Details")
            }
            .build()
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Simple")
            }

        // List with custom actions
        DynamicListBuilder<User>()
            .title("Users with Actions")
            .items(users)
            .searchable()
            .rowContent { user in
                HStack {
                    Circle()
                        .fill(user.isActive ? Color.green : Color.red)
                        .frame(width: 25, height: 25)

                    VStack(alignment: .leading) {
                        Text(user.name).font(.body)
                        Text(user.email).font(.caption).foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { print("Tapped on: \(user.name)") }) {
                        Image(systemName: "hand.tap").foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .detailContent { user in
                VStack(spacing: 16) {
                    Text(user.name).font(.title).fontWeight(.bold)
                    Text(user.email).font(.headline).foregroundColor(.secondary)
                    Text("Role: \(user.role)").font(.body)
                    Text("Status: \(user.isActive ? "Active" : "Inactive")")
                        .font(.body)
                        .foregroundColor(user.isActive ? .green : .red)
                    Spacer()
                }
                .padding()
                .navigationTitle("User Detail")
            }
            .build()
            .tabItem {
                Image(systemName: "person.2")
                Text("Users")
            }
    }
}
