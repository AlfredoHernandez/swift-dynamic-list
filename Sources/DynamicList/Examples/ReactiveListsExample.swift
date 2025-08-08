//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Reactive Lists Example

#Preview("Reactive Lists - Publishers & Error Handling") {
    TabView {
        // Success case with delay
        DynamicListBuilder<Fruit>()
            .title("Reactive Success")
            .publisher {
                Just(fruits)
                    .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .rowContent { fruit in
                HStack {
                    Text(fruit.symbol).font(.title2)
                    Text(fruit.name).foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .detailContent { fruit in
                VStack(spacing: 20) {
                    Text(fruit.symbol).font(.system(size: 100))
                    Text(fruit.name).font(.largeTitle).bold()
                    Text("Loaded from Publisher").font(.headline).foregroundColor(.secondary)
                }
                .navigationTitle("Details")
            }
            .skeletonContent { DefaultSkeletonView() }
            .build()
            .tabItem {
                Image(systemName: "arrow.clockwise")
                Text("Success")
            }

        // Error case with custom error view
        DynamicListBuilder<Fruit>()
            .title("Reactive Error")
            .publisher {
                Fail<[Fruit], Error>(error: LoadError.networkError)
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .rowContent { fruit in
                Text(fruit.name)
            }
            .detailContent { fruit in
                Text("Detail: \(fruit.name)")
            }
            .errorContent { error in
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash").font(.system(size: 60)).foregroundColor(.red)
                    Text("Oops!").font(.largeTitle).fontWeight(.bold)
                    Text(error.localizedDescription)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button("Retry") {}.buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            }
            .skeletonContent { DefaultSkeletonView() }
            .build()
            .tabItem {
                Image(systemName: "exclamationmark.triangle")
                Text("Error")
            }
    }
}
