//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

@Suite("DynamicListPresenter Tests")
struct DynamicListPresenterTests {
    // MARK: - Loading States Tests

    @Test("when loadingContent is accessed returns localized string")
    func whenLoadingContentIsAccessed_returnsLocalizedString() {
        let expected = localized("loading_content")
        #expect(DynamicListPresenter.loadingContent == expected)
    }

    // MARK: - Error Messages Tests

    @Test("when networkError is accessed returns localized string")
    func whenNetworkErrorIsAccessed_returnsLocalizedString() {
        let expected = localized("network_error")
        #expect(DynamicListPresenter.networkError == expected)
    }

    // MARK: - Error Actions Tests

    @Test("when retry is accessed returns localized string")
    func whenRetryIsAccessed_returnsLocalizedString() {
        let expected = localized("retry")
        #expect(DynamicListPresenter.retry == expected)
    }

    // MARK: - Navigation Tests

    @Test("when profile is accessed returns localized string")
    func whenProfileIsAccessed_returnsLocalizedString() {
        let expected = localized("profile")
        #expect(DynamicListPresenter.profile == expected)
    }

    @Test("when detail is accessed returns localized string")
    func whenDetailIsAccessed_returnsLocalizedString() {
        let expected = localized("detail")
        #expect(DynamicListPresenter.detail == expected)
    }

    @Test("when userDetail is accessed returns localized string")
    func whenUserDetailIsAccessed_returnsLocalizedString() {
        let expected = localized("user_detail")
        #expect(DynamicListPresenter.userDetail == expected)
    }

    @Test("when productDetail is accessed returns localized string")
    func whenProductDetailIsAccessed_returnsLocalizedString() {
        let expected = localized("product_detail")
        #expect(DynamicListPresenter.productDetail == expected)
    }

    // MARK: - Content Labels Tests

    @Test("when itemID is accessed returns localized string")
    func whenItemIDIsAccessed_returnsLocalizedString() {
        let expected = localized("item_id")
        #expect(DynamicListPresenter.itemID == expected)
    }

    // MARK: - Default Views Tests

    @Test("when itemDetail is accessed returns localized string")
    func whenItemDetailIsAccessed_returnsLocalizedString() {
        let expected = localized("item_detail")
        #expect(DynamicListPresenter.itemDetail == expected)
    }

    @Test("when errorLoadingData is accessed returns localized string")
    func whenErrorLoadingDataIsAccessed_returnsLocalizedString() {
        let expected = localized("error_loading_data")
        #expect(DynamicListPresenter.errorLoadingData == expected)
    }

    // MARK: - Test Helpers

    /// Returns the localized string for the given key
    /// - Parameters:
    ///   - key: The localization key
    ///   - param: Optional parameter for string formatting
    ///   - table: The strings table name (defaults to "Localizable")
    /// - Returns: The localized string
    private func localized(_ key: String, param: CVarArg? = nil, table: String = "Localizable") -> String {
        let bundle = Bundle.module
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        // Verify that the key exists (if it doesn't, localizedString returns the key itself)
        #expect(value != key, "Missing localized string for key: '\(key)' in table: '\(table)'")

        if let param {
            return String(format: value, param)
        }
        return value
    }
}
