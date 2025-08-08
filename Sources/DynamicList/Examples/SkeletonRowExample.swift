//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Skeleton Row Examples

#Preview("Simple Skeleton Row") {
    DynamicListBuilder<User>()
        .title("Custom Skeleton")
        .simulatedPublisher(users, delay: 3.0)
        .skeletonRow(count: 5) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 18)
                        .frame(maxWidth: .infinity * 0.7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 14)
                        .frame(maxWidth: .infinity * 0.5)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .rowContent { user in
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold),
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .build()
}

#Preview("Sectioned Skeleton Row") {
    SectionedDynamicListBuilder<Product>()
        .title("Custom Sectioned Skeleton")
        .sections([
            ListSection(title: "Electronics", items: Array(products.prefix(3))),
            ListSection(title: "Audio", items: Array(products.dropFirst(8).prefix(3))),
        ])
        .skeletonRow(sections: 2, itemsPerSection: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .frame(maxWidth: .infinity * 0.8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .frame(maxWidth: .infinity * 0.4)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .rowContent { product in
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "cube.box.fill")
                            .foregroundColor(.white),
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .build()
}
