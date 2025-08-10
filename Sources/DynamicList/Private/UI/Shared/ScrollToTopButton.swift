//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// A reusable component that provides scroll-to-top functionality for lists.
///
/// This component combines ScrollViewReader with a floating action button that appears
/// when there are enough items in a list and allows users to quickly navigate to the top
/// with a smooth animation.
struct ScrollToTopButton<Content: View>: View {
    private let itemCount: Int
    private let scrollTarget: String
    private let minimumItemsToShow: Int
    private let content: Content

    /// Creates a scroll to top button wrapper.
    /// - Parameters:
    ///   - itemCount: The total number of items in the list
    ///   - scrollTarget: The ID of the element to scroll to
    ///   - minimumItemsToShow: Minimum number of items required to show the button (default: 5)
    ///   - content: The content view that contains the scrollable list
    init(itemCount: Int, scrollTarget: String, minimumItemsToShow: Int = 5, @ViewBuilder content: () -> Content) {
        self.itemCount = itemCount
        self.scrollTarget = scrollTarget
        self.minimumItemsToShow = minimumItemsToShow
        self.content = content()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                content

                if shouldShowButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(scrollTarget, anchor: .top)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.white)
                            .background(Circle().fill(.primary))
                            .shadow(radius: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private var shouldShowButton: Bool {
        itemCount > minimumItemsToShow
    }
}

// MARK: - Preview

#Preview("ScrollToTopButton - With Many Items") {
    ScrollToTopButton(itemCount: 20, scrollTarget: "firstItem") {
        List(0 ..< 20, id: \.self) { index in
            HStack {
                Text("Item \(index)")
                Spacer()
            }
            .id(index == 0 ? "firstItem" : nil)
        }
    }
}

#Preview("ScrollToTopButton - With Few Items") {
    ScrollToTopButton(itemCount: 3, scrollTarget: "firstItem") {
        List(0 ..< 3, id: \.self) { index in
            HStack {
                Text("Item \(index)")
                Spacer()
            }
            .id(index == 0 ? "firstItem" : nil)
        }
    }
}
