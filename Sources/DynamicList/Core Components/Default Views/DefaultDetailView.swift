//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Default detail view used when no custom detail content is provided.
///
/// This view displays a simple detail representation of the item with its
/// description and ID. It's used as a fallback when `detailContent` is not specified.
struct DefaultDetailView<Item: Identifiable & Hashable>: View {
    let item: Item

    var body: some View {
        VStack(spacing: 16) {
            Text(DynamicListPresenter.itemDetail)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(String(describing: item))")
                .font(.body)

            Text("\(DynamicListPresenter.itemID): \(String(describing: item.id))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
