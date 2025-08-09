//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

// MARK: - String Utilities

/// Normalizes a string for case-insensitive comparison.
/// This is a pure function that can be composed with other string operations.
func normalizeString(_ string: String) -> String {
    string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Tokenizes a string into individual words.
/// This is a pure function that can be composed with other string operations.
func tokenizeString(_ string: String) -> [String] {
    normalizeString(string)
        .split(separator: " ")
        .map(String.init)
        .filter { !$0.isEmpty }
}
