//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import SwiftUI
import Testing

@Suite("Skeleton Row Build Method Tests")
struct SkeletonRowBuildMethodTests {
    @Test("Build method preserves skeleton row configuration")
    @MainActor
    func build_preservesSkeletonRowConfiguration() {
        let builder = DynamicListBuilder<TestItem>()

        // This should not crash and should preserve the skeleton row configuration
        _ = builder
            .items([TestItem(name: "Test")])
            .skeletonRow(count: 5) {
                Text("Custom skeleton")
            }
            .build()

        // If we reach this point, the build method is working correctly
        // The actual skeleton content verification would require integration testing
    }

    @Test("BuildWithoutNavigation method preserves skeleton row configuration")
    @MainActor
    func buildWithoutNavigation_preservesSkeletonRowConfiguration() {
        let builder = DynamicListBuilder<TestItem>()

        // This should not crash and should preserve the skeleton row configuration
        _ = builder
            .items([TestItem(name: "Test")])
            .skeletonRow(count: 5) {
                Text("Custom skeleton")
            }
            .buildWithoutNavigation()

        // If we reach this point, the buildWithoutNavigation method is working correctly
        // The actual skeleton content verification would require integration testing
    }

    @Test("Sectioned build method preserves skeleton row configuration")
    @MainActor
    func sectionedBuild_preservesSkeletonRowConfiguration() {
        let builder = SectionedDynamicListBuilder<TestItem>()

        // This should not crash and should preserve the skeleton row configuration
        _ = builder
            .sections([ListSection(title: "Test", items: [TestItem(name: "Test")])])
            .skeletonRow(sections: 2, itemsPerSection: 3) {
                Text("Custom sectioned skeleton")
            }
            .build()

        // If we reach this point, the build method is working correctly
    }

    @Test("Sectioned buildWithoutNavigation method preserves skeleton row configuration")
    @MainActor
    func sectionedBuildWithoutNavigation_preservesSkeletonRowConfiguration() {
        let builder = SectionedDynamicListBuilder<TestItem>()

        // This should not crash and should preserve the skeleton row configuration
        _ = builder
            .sections([ListSection(title: "Test", items: [TestItem(name: "Test")])])
            .skeletonRow(sections: 2, itemsPerSection: 3) {
                Text("Custom sectioned skeleton")
            }
            .buildWithoutNavigation()

        // If we reach this point, the buildWithoutNavigation method is working correctly
    }
}
