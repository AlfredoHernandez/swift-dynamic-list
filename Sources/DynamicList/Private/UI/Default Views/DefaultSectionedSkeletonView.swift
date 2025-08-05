//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

/// Default skeleton view for sectioned loading states
public struct DefaultSectionedSkeletonView: View {
    public init() {}

    public var body: some View {
        List {
            ForEach(0 ..< 3, id: \.self) { sectionIndex in
                Section {
                    ForEach(0 ..< (sectionIndex + 2), id: \.self) { _ in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 16)
                                    .frame(maxWidth: .infinity)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                    .frame(maxWidth: .infinity * 0.7)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity * 0.5)
                }
            }
        }
        .redacted(reason: .placeholder)
    }
}

// MARK: - Previews

#Preview("Sectioned Skeleton") {
    DefaultSectionedSkeletonView()
        .navigationTitle("Cargando...")
}

#Preview("Sectioned Skeleton in Navigation") {
    NavigationStack {
        DefaultSectionedSkeletonView()
            .navigationTitle("Usuarios por Rol")
    }
}

#Preview("Sectioned Skeleton with Background") {
    DefaultSectionedSkeletonView()
        .background(Color.gray.opacity(0.1))
}
