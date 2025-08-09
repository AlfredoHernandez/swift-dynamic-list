//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
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

#Preview("Custom Skeleton Examples") {
    TabView {
        // Simple skeleton row example
        DynamicListBuilder<Product>()
            .simulatedPublisher(products, delay: 3.0)
            .title("Simple Skeleton")
            .skeletonRow(count: 5) {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)
                            .frame(maxWidth: .infinity * 0.7)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .frame(maxWidth: .infinity * 0.5)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .build()
            .tabItem {
                Image(systemName: "rectangle.dashed")
                Text("Simple")
            }

        // Sectioned skeleton with header only
        SectionedDynamicListBuilder<Product>()
            .publisher {
                Just([
                    products.filter { $0.category == "Electronics" },
                    products.filter { $0.category == "Audio" },
                ])
                .delay(for: .seconds(4), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .title("Sectioned with Header")
            .skeletonRow(
                sections: 2,
                itemsPerSection: 3,
                rowContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 18)
                                .frame(maxWidth: .infinity * 0.8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity * 0.6)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                },
                headerContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.4))
                            .frame(height: 25)
                            .frame(maxWidth: .infinity * 0.6)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                },
            )
            .build()
            .tabItem {
                Image(systemName: "rectangle.stack.badge.plus")
                Text("Header")
            }

        // Sectioned skeleton with header and footer
        SectionedDynamicListBuilder<Product>()
            .publisher {
                Just([
                    products.filter { $0.category == "Electronics" },
                    products.filter { $0.category == "Audio" },
                ])
                .delay(for: .seconds(5), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .title("Complete Skeleton")
            .skeletonRow(
                sections: 2,
                itemsPerSection: 4,
                rowContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 18)
                                .frame(maxWidth: .infinity * 0.8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity * 0.6)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                },
                headerContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.4))
                            .frame(height: 25)
                            .frame(maxWidth: .infinity * 0.6)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                },
                footerContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.purple.opacity(0.3))
                            .frame(height: 12)
                            .frame(maxWidth: .infinity * 0.4)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                },
            )
            .build()
            .tabItem {
                Image(systemName: "rectangle.stack.fill.badge.plus")
                Text("Complete")
            }

        // Sectioned skeleton with footer only
        SectionedDynamicListBuilder<Product>()
            .publisher {
                Just([
                    products.filter { $0.category == "Electronics" },
                    products.filter { $0.category == "Audio" },
                ])
                .delay(for: .seconds(3), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .title("Footer Only Skeleton")
            .skeletonRow(
                sections: 2,
                itemsPerSection: 3,
                rowContent: {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 45, height: 45)
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 16)
                                .frame(maxWidth: .infinity * 0.75)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                                .frame(maxWidth: .infinity * 0.55)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                },
                footerContent: {
                    HStack {
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green.opacity(0.4))
                            .frame(width: 30, height: 8)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                },
            )
            .build()
            .tabItem {
                Image(systemName: "rectangle.stack.badge.minus")
                Text("Footer Only")
            }

        // Skeleton on refresh example
        SectionedDynamicListBuilder<Product>()
            .publisher {
                Just([
                    products.filter { $0.category == "Electronics" },
                    products.filter { $0.category == "Audio" },
                ])
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .title("Skeleton on Refresh")
            .skeletonRow(
                sections: 2,
                itemsPerSection: 4,
                rowContent: {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.4))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity * 0.7)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 10)
                                .frame(maxWidth: .infinity * 0.5)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                },
                headerContent: {
                    Text("Loading Section...")
                        .font(.headline)
                        .foregroundColor(.blue.opacity(0.6))
                },
            )
            .showSkeletonOnRefresh() // 🎯 Esta es la nueva funcionalidad
            .build()
            .tabItem {
                Image(systemName: "arrow.clockwise.circle")
                Text("Refresh Skeleton")
            }
    }
}
