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

    @Test("when query is empty returns true for all items")
    func whenQueryIsEmpty_returnsTrueForAllItems() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "Test Item",
            description: "A test description",
            tags: ["tag1", "tag2"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    @Test("when query matches name returns true")
    func whenQueryMatchesName_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == true)
    }

    @Test("when query matches description returns true")
    func whenQueryMatchesDescription_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "MacBook",
            description: "Latest smartphone with advanced features",
            tags: ["laptop", "apple"],
        )

        let result = strategy.matches(query: "smartphone", in: item)

        #expect(result == true)
    }

    @Test("when query matches tag returns true")
    func whenQueryMatchesTag_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "AirPods",
            description: "Wireless headphones",
            tags: ["audio", "wireless", "bluetooth"],
        )

        let result = strategy.matches(query: "bluetooth", in: item)

        #expect(result == true)
    }

    @Test("when query is case insensitive matches correctly")
    func whenQueryIsCaseInsensitive_matchesCorrectly() throws {
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

    @Test("when query does not match any key returns false")
    func whenQueryDoesNotMatchAnyKey_returnsFalse() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "nonexistent", in: item)

        #expect(result == false)
    }

    @Test("when query is partial match returns true")
    func whenQueryIsPartialMatch_returnsTrue() throws {
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

    @Test("when query exactly matches name returns true")
    func whenQueryExactlyMatchesName_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone 15 Pro", in: item)

        #expect(result == true)
    }

    @Test("when query exactly matches description returns true")
    func whenQueryExactlyMatchesDescription_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "MacBook",
            description: "Latest smartphone",
            tags: ["laptop", "apple"],
        )

        let result = strategy.matches(query: "Latest smartphone", in: item)

        #expect(result == true)
    }

    @Test("when query exactly matches tag returns true")
    func whenQueryExactlyMatchesTag_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "AirPods",
            description: "Wireless headphones",
            tags: ["audio", "wireless", "bluetooth"],
        )

        let result = strategy.matches(query: "bluetooth", in: item)

        #expect(result == true)
    }

    @Test("when query is case insensitive exact match returns true")
    func whenQueryIsCaseInsensitiveExactMatch_returnsTrue() throws {
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

    @Test("when query is partial match returns false")
    func whenQueryIsPartialMatch_returnsFalse() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == false)
    }

    @Test("when query does not match any key exactly returns false")
    func whenQueryDoesNotMatchAnyKeyExactly_returnsFalse() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "nonexistent", in: item)

        #expect(result == false)
    }

    @Test("when query is empty returns true")
    func whenQueryIsEmpty_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    // MARK: - TokenizedMatchStrategy Tests

    @Test("when query is empty returns true")
    func whenQueryIsEmpty_returnsTrueForTokenized() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "", in: item)

        #expect(result == true)
    }

    @Test("when all query tokens match returns true")
    func whenAllQueryTokensMatch_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone Pro", in: item)

        #expect(result == true)
    }

    @Test("when some query tokens match returns false")
    func whenSomeQueryTokensMatch_returnsFalse() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone Nonexistent", in: item)

        #expect(result == false)
    }

    @Test("when query tokens match across different keys returns true")
    func whenQueryTokensMatchAcrossDifferentKeys_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone advanced", in: item)

        #expect(result == true)
    }

    @Test("when query tokens are case insensitive matches correctly")
    func whenQueryTokensAreCaseInsensitive_matchesCorrectly() throws {
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

    @Test("when query has single token matches correctly")
    func whenQueryHasSingleToken_matchesCorrectly() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone", in: item)

        #expect(result == true)
    }

    @Test("when query has multiple spaces handles correctly")
    func whenQueryHasMultipleSpaces_handlesCorrectly() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"],
        )

        let result = strategy.matches(query: "iPhone   Pro", in: item)

        #expect(result == true)
    }

    @Test("when item has empty search keys returns false for non-empty query")
    func whenItemHasEmptySearchKeys_returnsFalseForNonEmptyQuery() throws {
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

    @Test("when searchable item has empty search keys returns false")
    func whenSearchableItemHasEmptySearchKeys_returnsFalse() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "",
            description: "",
            tags: [],
        )

        let result = strategy.matches(query: "test", in: item)

        #expect(result == false)
    }

    @Test("when searchable item has whitespace only keys handles correctly")
    func whenSearchableItemHasWhitespaceOnlyKeys_handlesCorrectly() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "   ",
            description: "  \t  ",
            tags: ["", "   "],
        )

        let result = strategy.matches(query: "test", in: item)

        #expect(result == false)
    }

    @Test("when query contains special characters handles correctly")
    func whenQueryContainsSpecialCharacters_handlesCorrectly() throws {
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
