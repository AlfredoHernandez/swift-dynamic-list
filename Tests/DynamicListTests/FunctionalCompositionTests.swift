//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

@Suite
struct FunctionalTests {
    // MARK: - String Utilities Tests

    @Test("when string is empty returns empty string")
    func whenStringIsEmpty_returnsEmptyString() throws {
        let result = normalizeString("")
        #expect(result == "")
    }

    @Test("when string contains only whitespace returns empty string")
    func whenStringContainsOnlyWhitespace_returnsEmptyString() throws {
        let result1 = normalizeString("   ")
        let result2 = normalizeString("\t\n")
        let result3 = normalizeString("  \t  \n  ")

        #expect(result1 == "")
        #expect(result2 == "")
        #expect(result3 == "")
    }

    @Test("when string has mixed case and whitespace normalizes correctly")
    func whenStringHasMixedCaseAndWhitespace_normalizesCorrectly() throws {
        let result = normalizeString("  Hello World  ")
        #expect(result == "hello world")
    }

    @Test("when string has special characters normalizes correctly")
    func whenStringHasSpecialCharacters_normalizesCorrectly() throws {
        let result = normalizeString("  iPhone 15 Pro (2024)  ")
        #expect(result == "iphone 15 pro (2024)")
    }

    // MARK: - Tokenization Tests

    @Test("when string is empty returns empty array")
    func whenStringIsEmpty_returnsEmptyArray() throws {
        let result = tokenizeString("")
        #expect(result == [])
    }

    @Test("when string contains only whitespace returns empty array")
    func whenStringContainsOnlyWhitespace_returnsEmptyArray() throws {
        let result1 = tokenizeString("   ")
        let result2 = tokenizeString("\t\n")
        let result3 = tokenizeString("  \t  \n  ")

        #expect(result1 == [])
        #expect(result2 == [])
        #expect(result3 == [])
    }

    @Test("when string has single word returns single token")
    func whenStringHasSingleWord_returnsSingleToken() throws {
        let result = tokenizeString("Hello")
        #expect(result == ["hello"])
    }

    @Test("when string has multiple words returns multiple tokens")
    func whenStringHasMultipleWords_returnsMultipleTokens() throws {
        let result = tokenizeString("Hello World")
        #expect(result == ["hello", "world"])
    }

    @Test("when string has multiple spaces between words handles correctly")
    func whenStringHasMultipleSpacesBetweenWords_handlesCorrectly() throws {
        let result = tokenizeString("Hello   World")
        #expect(result == ["hello", "world"])
    }

    @Test("when string has mixed case normalizes tokens")
    func whenStringHasMixedCase_normalizesTokens() throws {
        let result = tokenizeString("Hello WORLD")
        #expect(result == ["hello", "world"])
    }

    @Test("when string has leading and trailing whitespace trims correctly")
    func whenStringHasLeadingAndTrailingWhitespace_trimsCorrectly() throws {
        let result = tokenizeString("  Hello World  ")
        #expect(result == ["hello", "world"])
    }
}
