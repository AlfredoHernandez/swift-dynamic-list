//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

@Suite
struct FunctionalTests {
    // MARK: - String Utilities Tests

    @Test("NormalizeString returns empty string on empty input")
    func normalizeString_returnsEmptyStringOnEmptyInput() throws {
        let result = normalizeString("")
        #expect(result == "")
    }

    @Test("NormalizeString returns empty string on whitespace only input")
    func normalizeString_returnsEmptyStringOnWhitespaceOnlyInput() throws {
        let result1 = normalizeString("   ")
        let result2 = normalizeString("\t\n")
        let result3 = normalizeString("  \t  \n  ")

        #expect(result1 == "")
        #expect(result2 == "")
        #expect(result3 == "")
    }

    @Test("NormalizeString normalizes mixed case and whitespace")
    func normalizeString_normalizesMixedCaseAndWhitespace() throws {
        let result = normalizeString("  Hello World  ")
        #expect(result == "hello world")
    }

    @Test("NormalizeString normalizes special characters")
    func normalizeString_normalizesSpecialCharacters() throws {
        let result = normalizeString("  iPhone 15 Pro (2024)  ")
        #expect(result == "iphone 15 pro (2024)")
    }

    // MARK: - Tokenization Tests

    @Test("TokenizeString returns empty array on empty input")
    func tokenizeString_returnsEmptyArrayOnEmptyInput() throws {
        let result = tokenizeString("")
        #expect(result == [])
    }

    @Test("TokenizeString returns empty array on whitespace only input")
    func tokenizeString_returnsEmptyArrayOnWhitespaceOnlyInput() throws {
        let result1 = tokenizeString("   ")
        let result2 = tokenizeString("\t\n")
        let result3 = tokenizeString("  \t  \n  ")

        #expect(result1 == [])
        #expect(result2 == [])
        #expect(result3 == [])
    }

    @Test("TokenizeString returns single token on single word")
    func tokenizeString_returnsSingleTokenOnSingleWord() throws {
        let result = tokenizeString("Hello")
        #expect(result == ["hello"])
    }

    @Test("TokenizeString returns multiple tokens on multiple words")
    func tokenizeString_returnsMultipleTokensOnMultipleWords() throws {
        let result = tokenizeString("Hello World")
        #expect(result == ["hello", "world"])
    }

    @Test("TokenizeString handles multiple spaces between words correctly")
    func tokenizeString_handlesMultipleSpacesBetweenWordsCorrectly() throws {
        let result = tokenizeString("Hello   World")
        #expect(result == ["hello", "world"])
    }

    @Test("TokenizeString normalizes tokens on mixed case")
    func tokenizeString_normalizesTokensOnMixedCase() throws {
        let result = tokenizeString("Hello WORLD")
        #expect(result == ["hello", "world"])
    }

    @Test("TokenizeString trims leading and trailing whitespace correctly")
    func tokenizeString_trimsLeadingAndTrailingWhitespaceCorrectly() throws {
        let result = tokenizeString("  Hello World  ")
        #expect(result == ["hello", "world"])
    }
}
