//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Configuration for skeleton row generation
struct SkeletonRowConfiguration {
    let count: Int
    let listStyle: ListStyleType
    let rowContentBuilder: () -> AnyView

    init(count: Int, listStyle: ListStyleType, @ViewBuilder rowContent: @escaping () -> some View) {
        self.count = count
        self.listStyle = listStyle
        rowContentBuilder = { AnyView(rowContent()) }
    }
}

/// Configuration for sectioned skeleton generation
struct SectionedSkeletonRowConfiguration {
    let sections: Int
    let itemsPerSection: Int
    let listStyle: ListStyleType
    let rowContentBuilder: () -> AnyView
    let headerContentBuilder: (() -> AnyView)?
    let footerContentBuilder: (() -> AnyView)?

    init(
        sections: Int,
        itemsPerSection: Int,
        listStyle: ListStyleType,
        @ViewBuilder rowContent: @escaping () -> some View,
        headerContent: (() -> AnyView)? = nil,
        footerContent: (() -> AnyView)? = nil,
    ) {
        self.sections = sections
        self.itemsPerSection = itemsPerSection
        self.listStyle = listStyle
        rowContentBuilder = { AnyView(rowContent()) }
        headerContentBuilder = headerContent
        footerContentBuilder = footerContent
    }
}
