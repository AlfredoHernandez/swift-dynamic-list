//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

// MARK: - Localization Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LocalizationExamplesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Localization Examples") {
                    NavigationLink("Localized Error Views") {
                        LocalizedErrorExamples()
                    }

                    NavigationLink("Localized Loading States") {
                        LocalizedLoadingExamples()
                    }

                    NavigationLink("Localized Content") {
                        LocalizedContentExamples()
                    }

                    NavigationLink("Multi-Language Demo") {
                        MultiLanguageDemo()
                    }
                }
            }
            .navigationTitle("Localization")
        }
    }
}

// MARK: - Localized Error Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LocalizedErrorExamples: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Localized Error Messages")
                    .font(.title)
                    .fontWeight(.bold)

                // Network Error
                LocalizedErrorCard(
                    title: DynamicListPresenter.errorLoading,
                    message: DynamicListPresenter.networkError,
                    icon: "wifi.slash",
                )

                // Server Error
                LocalizedErrorCard(
                    title: DynamicListPresenter.errorLoading,
                    message: DynamicListPresenter.serverError,
                    icon: "server.rack",
                )

                // Unauthorized Error
                LocalizedErrorCard(
                    title: DynamicListPresenter.errorLoading,
                    message: DynamicListPresenter.unauthorizedAccess,
                    icon: "lock.shield",
                )

                // Data Corrupted Error
                LocalizedErrorCard(
                    title: DynamicListPresenter.errorLoading,
                    message: DynamicListPresenter.dataCorrupted,
                    icon: "exclamationmark.triangle",
                )

                // Connection Timeout Error
                LocalizedErrorCard(
                    title: DynamicListPresenter.errorLoading,
                    message: DynamicListPresenter.connectionTimeout,
                    icon: "clock.badge.exclamationmark",
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Error Examples")
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LocalizedErrorCard: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.red)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            HStack {
                Button(DynamicListPresenter.retry) {
                    // Retry action
                }
                .buttonStyle(.borderedProminent)

                Button(DynamicListPresenter.cancel) {
                    // Cancel action
                }
                .buttonStyle(.bordered)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Localized Loading Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LocalizedLoadingExamples: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Localized Loading States")
                .font(.title)
                .fontWeight(.bold)

            // General Loading
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text(DynamicListPresenter.loadingContent)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Users Loading
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text(DynamicListPresenter.loadingUsers)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Products Loading
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text(DynamicListPresenter.loadingProducts)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle("Loading Examples")
    }
}

// MARK: - Localized Content Examples

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct LocalizedContentExamples: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Localized Content Labels")
                    .font(.title)
                    .fontWeight(.bold)

                // Product Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("iPhone 15 Pro")
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text("\(DynamicListPresenter.category):")
                            .font(.headline)
                        Text("Electronics")
                            .font(.body)
                        Spacer()
                    }

                    HStack {
                        Text("\(DynamicListPresenter.price):")
                            .font(.headline)
                        Text("$999.99")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Spacer()
                    }

                    HStack {
                        Text("\(DynamicListPresenter.itemID):")
                            .font(.headline)
                        Text("12345")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    HStack {
                        Text(DynamicListPresenter.available)
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)

                        Spacer()

                        Button(DynamicListPresenter.buyNow) {
                            // Buy action
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Navigation Examples
                VStack(alignment: .leading, spacing: 12) {
                    Text("Navigation Titles")
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• \(DynamicListPresenter.profile)")
                        Text("• \(DynamicListPresenter.detail)")
                        Text("• \(DynamicListPresenter.userDetail)")
                        Text("• \(DynamicListPresenter.productDetail)")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Content Examples")
    }
}

// MARK: - Multi-Language Demo

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
struct MultiLanguageDemo: View {
    @State private var selectedLanguage = "en"

    var body: some View {
        VStack(spacing: 20) {
            Text("Multi-Language Demo")
                .font(.title)
                .fontWeight(.bold)

            Text("Change your device language to see the localization in action!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Language Selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Supported Languages:")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("🇺🇸 English (en)")
                    Text("🇲🇽 Spanish - Mexico (es-MX)")
                    Text("🇫🇷 French (fr)")
                    Text("🇧🇷 Portuguese (pt)")
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Current Language Display
            VStack(spacing: 16) {
                Text("Current Language")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(selectedLanguage.uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Sample Localized Content
            VStack(spacing: 16) {
                Text("Sample Localized Content")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: 8) {
                    Text(DynamicListPresenter.loadingContent)
                    Text(DynamicListPresenter.networkError)
                    Text(DynamicListPresenter.retry)
                    Text(DynamicListPresenter.profile)
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle("Multi-Language")
    }
}

// MARK: - Previews

#Preview("Localization Examples") {
    LocalizationExamplesView()
}

#Preview("Error Examples") {
    LocalizedErrorExamples()
}

#Preview("Loading Examples") {
    LocalizedLoadingExamples()
}

#Preview("Content Examples") {
    LocalizedContentExamples()
}

#Preview("Multi-Language Demo") {
    MultiLanguageDemo()
}
