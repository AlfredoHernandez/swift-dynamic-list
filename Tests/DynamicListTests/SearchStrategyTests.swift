//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

// MARK: - Test Models

struct TestSearchableItem: Searchable {
    let id = UUID()
    let name: String
    let description: String
    let tags: [String]

    var searchKeys: [String] {
        [name, description] + tags
    }
}

// MARK: - SearchStrategy Tests

@Suite
struct SearchStrategyTests {
    // MARK: - PartialMatchStrategy Tests

    @Test("PartialMatchStrategy returns true on empty query")
    func partialMatchStrategy_returnsTrueOnEmptyQuery() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "Test Item",
            description: "A test description",
            tags: ["tag1", "tag2"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    @Test("PartialMatchStrategy returns true when query matches name")
    func partialMatchStrategy_returnsTrueWhenQueryMatchesName() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == true)
    }

    @Test("PartialMatchStrategy returns true when query matches description")
    func partialMatchStrategy_returnsTrueWhenQueryMatchesDescription() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "MacBook",
            description: "Latest smartphone with advanced features",
            tags: ["laptop", "apple"],
        )

        let result = strategy.matches(query: "smartphone", in: item)

        #expect(result == true)
    }

    @Test("PartialMatchStrategy returns true when query matches tag")
    func partialMatchStrategy_returnsTrueWhenQueryMatchesTag() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "AirPods",
            description: "Wireless headphones",
            tags: ["audio", "wireless", "bluetooth"],
        )

        let result = strategy.matches(query: "bluetooth", in: item)

        #expect(result == true)
    }

    @Test("PartialMatchStrategy matches correctly with case insensitive query")
    func partialMatchStrategy_matchesCorrectlyWithCaseInsensitiveQuery() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result1 = strategy.matches(query: "iphone", in: item)
        let result2 = strategy.matches(query: "IPHONE", in: item)
        let result3 = strategy.matches(query: "iPhone", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }

    @Test("PartialMatchStrategy returns false when query matches no key")
    func partialMatchStrategy_returnsFalseWhenQueryMatchesNoKey() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "nonexistent", in: item)

        #expect(result == false)
    }

    @Test("PartialMatchStrategy returns true on partial match")
    func partialMatchStrategy_returnsTrueOnPartialMatch() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "MacBook Pro M3",
            description: "Professional laptop",
            tags: ["laptop", "professional"],
        )

        let result = strategy.matches(query: "Mac", in: item)

        #expect(result == true)
    }

    // MARK: - ExactMatchStrategy Tests

    @Test("ExactMatchStrategy returns true when query exactly matches name")
    func exactMatchStrategy_returnsTrueWhenQueryExactlyMatchesName() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone 15 Pro", in: item)

        #expect(result == true)
    }

    @Test("ExactMatchStrategy returns true when query exactly matches description")
    func exactMatchStrategy_returnsTrueWhenQueryExactlyMatchesDescription() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "MacBook",
            description: "Latest smartphone",
            tags: ["laptop", "apple"],
        )

        let result = strategy.matches(query: "Latest smartphone", in: item)

        #expect(result == true)
    }

    @Test("ExactMatchStrategy returns true when query exactly matches tag")
    func exactMatchStrategy_returnsTrueWhenQueryExactlyMatchesTag() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "AirPods",
            description: "Wireless headphones",
            tags: ["audio", "wireless", "bluetooth"],
        )

        let result = strategy.matches(query: "bluetooth", in: item)

        #expect(result == true)
    }

    @Test("ExactMatchStrategy returns true with case insensitive exact match")
    func exactMatchStrategy_returnsTrueWithCaseInsensitiveExactMatch() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result1 = strategy.matches(query: "iphone 15 pro", in: item)
        let result2 = strategy.matches(query: "IPHONE 15 PRO", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
    }

    @Test("ExactMatchStrategy returns false on partial match")
    func exactMatchStrategy_returnsFalseOnPartialMatch() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == false)
    }

    @Test("ExactMatchStrategy returns false when query matches no key exactly")
    func exactMatchStrategy_returnsFalseWhenQueryMatchesNoKeyExactly() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "nonexistent", in: item)

        #expect(result == false)
    }

    @Test("ExactMatchStrategy returns true on empty query")
    func exactMatchStrategy_returnsTrueOnEmptyQuery() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    @Test("ExactMatchStrategy returns true on whitespace only query")
    func exactMatchStrategy_returnsTrueOnWhitespaceOnlyQuery() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result1 = strategy.matches(query: "   ", in: item)
        let result2 = strategy.matches(query: "\t\n", in: item)
        let result3 = strategy.matches(query: "  \t  \n  ", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }

    @Test("ExactMatchStrategy handles whitespace in search keys correctly")
    func exactMatchStrategy_handlesWhitespaceInSearchKeysCorrectly() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "  iPhone 15 Pro  ",
            description: "  Latest smartphone  ",
            tags: ["  mobile  ", "  apple  "],
        )

        let result1 = strategy.matches(query: "iPhone 15 Pro", in: item)
        let result2 = strategy.matches(query: "Latest smartphone", in: item)
        let result3 = strategy.matches(query: "mobile", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }

    // MARK: - TokenizedMatchStrategy Tests

    @Test("TokenizedMatchStrategy returns true on empty query")
    func tokenizedMatchStrategy_returnsTrueOnEmptyQuery() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    @Test("TokenizedMatchStrategy returns true when all query tokens match")
    func tokenizedMatchStrategy_returnsTrueWhenAllQueryTokensMatch() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone Pro", in: item)

        #expect(result == true)
    }

    @Test("TokenizedMatchStrategy returns false when some query tokens match")
    func tokenizedMatchStrategy_returnsFalseWhenSomeQueryTokensMatch() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone Nonexistent", in: item)

        #expect(result == false)
    }

    @Test("TokenizedMatchStrategy returns true when query tokens match across different keys")
    func tokenizedMatchStrategy_returnsTrueWhenQueryTokensMatchAcrossDifferentKeys() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone advanced", in: item)

        #expect(result == true)
    }

    @Test("TokenizedMatchStrategy matches correctly with case insensitive query tokens")
    func tokenizedMatchStrategy_matchesCorrectlyWithCaseInsensitiveQueryTokens() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result1 = strategy.matches(query: "iphone pro", in: item)
        let result2 = strategy.matches(query: "IPHONE PRO", in: item)
        let result3 = strategy.matches(query: "iPhone Pro", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }

    @Test("TokenizedMatchStrategy matches correctly with single token query")
    func tokenizedMatchStrategy_matchesCorrectlyWithSingleTokenQuery() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == true)
    }

    @Test("TokenizedMatchStrategy handles multiple spaces in query correctly")
    func tokenizedMatchStrategy_handlesMultipleSpacesInQueryCorrectly() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone   Pro", in: item)

        #expect(result == true)
    }

    @Test("TokenizedMatchStrategy returns false for non-empty query when item has empty search keys")
    func tokenizedMatchStrategy_returnsFalseForNonEmptyQueryWhenItemHasEmptySearchKeys() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "",
            description: "",
            tags: [],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == false)
    }

    // MARK: - Edge Cases Tests

    @Test("PartialMatchStrategy returns false when searchable item has empty search keys")
    func partialMatchStrategy_returnsFalseWhenSearchableItemHasEmptySearchKeys() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "",
            description: "",
            tags: [],
        )

        let result = strategy.matches(query: "test", in: item)

        #expect(result == false)
    }

    @Test("PartialMatchStrategy handles whitespace only keys correctly")
    func partialMatchStrategy_handlesWhitespaceOnlyKeysCorrectly() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "   ",
            description: "  \t  ",
            tags: ["", "   "],
        )

        let result = strategy.matches(query: "test", in: item)

        #expect(result == false)
    }

    @Test("PartialMatchStrategy handles special characters in query correctly")
    func partialMatchStrategy_handlesSpecialCharactersInQueryCorrectly() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro (2024)",
            description: "Latest smartphone with 5G & WiFi 6E",
            tags: ["mobile", "5G", "WiFi-6E"],
        )

        let result1 = strategy.matches(query: "5G", in: item)
        let result2 = strategy.matches(query: "WiFi", in: item)
        let result3 = strategy.matches(query: "(2024)", in: item)

        #expect(result1 == true)
        #expect(result2 == true)
        #expect(result3 == true)
    }
}
