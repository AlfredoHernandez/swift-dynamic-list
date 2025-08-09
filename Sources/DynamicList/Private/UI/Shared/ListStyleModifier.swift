//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// ViewModifier to apply list styles consistently across different list components.
///
/// This modifier provides a unified way to apply list styles in both regular and sectioned lists,
/// ensuring consistency and avoiding code duplication.
struct ListStyleModifier: ViewModifier {
    let style: ListStyleType

    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.listStyle(.automatic)
        case .plain:
            content.listStyle(.plain)
        case .inset:
            content.listStyle(.inset)
        #if os(iOS)
        case .grouped:
            content.listStyle(.grouped)
        case .insetGrouped:
            content.listStyle(.insetGrouped)
        #endif
        }
    }
}
