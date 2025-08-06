//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Example demonstrating ListConfiguration usage.
///
/// This example shows how to use ListConfiguration to set multiple
/// list properties at once, similar to SearchConfiguration.
struct ListConfigurationExample: View {
    struct Task: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let priority: String
        let isCompleted: Bool
    }

    private let tasks = [
        Task(title: "Buy groceries", priority: "High", isCompleted: false),
        Task(title: "Call dentist", priority: "Medium", isCompleted: true),
        Task(title: "Read documentation", priority: "Low", isCompleted: false),
        Task(title: "Exercise", priority: "High", isCompleted: false),
        Task(title: "Plan vacation", priority: "Medium", isCompleted: true),
    ]

    var body: some View {
        TabView {
            // Using individual methods
            DynamicListBuilder<Task>()
                .title("Individual Methods")
                .items(tasks)
                .listStyle(.plain)
                .rowContent { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.priority)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .detailContent { task in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(task.title)
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Priority: \(task.priority)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Status: \(task.isCompleted ? "Completed" : "Pending")")
                                .font(.body)
                                .foregroundColor(task.isCompleted ? .green : .orange)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Task Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Individual")
                }

            // Using ListConfiguration
            DynamicListBuilder<Task>()
                .items(tasks)
                .listConfiguration(ListConfiguration(
                    style: .inset,
                    navigationBarHidden: false,
                    title: "ListConfiguration",
                ))
                .rowContent { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.priority)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .detailContent { task in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(task.title)
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Priority: \(task.priority)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Status: \(task.isCompleted ? "Completed" : "Pending")")
                                .font(.body)
                                .foregroundColor(task.isCompleted ? .green : .orange)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Task Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Config")
                }

            // Using factory methods
            DynamicListBuilder<Task>()
                .items(tasks)
                .listConfiguration(ListConfiguration.style(.plain))
                .title("Factory Methods")
                .rowContent { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.priority)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .detailContent { task in
                    AnyView(
                        VStack(spacing: 16) {
                            Text(task.title)
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Priority: \(task.priority)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("Status: \(task.isCompleted ? "Completed" : "Pending")")
                                .font(.body)
                                .foregroundColor(task.isCompleted ? .green : .orange)

                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Task Detail"),
                    )
                }
                .build()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("Factory")
                }
        }
    }
}

#Preview {
    ListConfigurationExample()
}
