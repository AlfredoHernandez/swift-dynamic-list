//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Default row view used when no custom row content is provided.
///
/// This view displays a simple representation of the item with its description
/// and ID. It's used as a fallback when `rowContent` is not specified.
struct DefaultRowView<Item: Identifiable & Hashable>: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text(String(describing: item))
                .font(.body)
            Text("ID: \(String(describing: item.id))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
