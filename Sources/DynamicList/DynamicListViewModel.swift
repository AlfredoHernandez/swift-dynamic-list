//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import Observation

/// An observable view model to hold and manage a collection of items for a `DynamicList`.
///
/// This view model uses the Observation framework to allow SwiftUI views to automatically
/// track changes to the `items` array.
@Observable
public final class DynamicListViewModel<Item: Identifiable & Hashable> {
    /// The collection of items to be displayed.
    public var items: [Item]

    /// Initializes the view model with an initial set of items.
    /// - Parameter items: The initial array of items. Defaults to an empty array.
    public init(items: [Item] = []) {
        self.items = items
    }
}
