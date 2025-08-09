//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - List Configuration Example

#Preview("List Configuration & Styles") {
    TabView {
        // Different list styles
        DynamicListBuilder<Product>()
            .title("Products - Plain Style")
            .items(products)
            .listStyle(.plain)
            .rowContent { product in
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.name).font(.headline)
                        Text(product.category).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .detailContent { product in
                VStack(spacing: 16) {
                    Text(product.name).font(.title).fontWeight(.bold)
                    Text(product.category).font(.headline).foregroundColor(.secondary)
                    Text("$\(product.price, specifier: "%.2f")").font(.title2).foregroundColor(.blue)
                    Spacer()
                }
                .padding()
                .navigationTitle("Product Detail")
            }
            .build()
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Plain")
            }

        // List with configuration
        DynamicListBuilder<Task>()
            .title("Tasks - Inset Style")
            .items(tasks)
            .listConfiguration(ListConfiguration(
                style: .inset,
                navigationBarHidden: false,
                title: "Task Configuration",
            ))
            .rowContent { task in
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title).font(.headline)
                        Text(task.priority).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    }
                }
            }
            .detailContent { task in
                VStack(spacing: 16) {
                    Text(task.title).font(.title).fontWeight(.bold)
                    Text("Priority: \(task.priority)").font(.headline).foregroundColor(.secondary)
                    Text("Status: \(task.isCompleted ? "Completed" : "Pending")")
                        .font(.body)
                        .foregroundColor(task.isCompleted ? .green : .orange)
                    Spacer()
                }
                .padding()
                .navigationTitle("Task Detail")
            }
            .build()
            .tabItem {
                Image(systemName: "gear")
                Text("Config")
            }
    }
}
