//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Sectioned Lists Example

#Preview("Sectioned Lists & Search") {
    TabView {
        // Sectioned list with static data
        SectionedDynamicListBuilder<Fruit>()
            .sections([
                ListSection(
                    title: "Red Fruits",
                    items: fruits.filter { $0.color == .red },
                    footer: "\(fruits.count(where: { $0.color == .red })) red fruits",
                ),
                ListSection(
                    title: "Green Fruits",
                    items: fruits.filter { $0.color == .green },
                    footer: "\(fruits.count(where: { $0.color == .green })) green fruits",
                ),
                ListSection(
                    title: "Yellow Fruits",
                    items: fruits.filter { $0.color == .yellow },
                    footer: "\(fruits.count(where: { $0.color == .yellow })) yellow fruits",
                ),
            ])
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
            .title("Fruits by Color")
            .build()
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Sectioned")
            }

        // Searchable list
        DynamicListBuilder<SearchableUser>()
            .title("Searchable Users")
            .items(searchableUsers)
            .searchable(prompt: "Search by name, email or role...")
            .rowContent { user in
                VStack(alignment: .leading) {
                    Text(user.name).font(.headline)
                    Text("\(user.role) • \(user.email)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .detailContent { user in
                VStack(spacing: 16) {
                    Text(user.name).font(.title).fontWeight(.bold)
                    Text(user.email).font(.headline).foregroundColor(.secondary)
                    Text("Role: \(user.role)").font(.body)
                    Spacer()
                }
                .padding()
                .navigationTitle("User Detail")
            }
            .build()
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
    }
}
