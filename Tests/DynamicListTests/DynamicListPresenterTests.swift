//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import DynamicList
import Foundation
import Testing

@Suite("DynamicListPresenter Tests")
struct DynamicListPresenterTests {
    // MARK: - Loading States Tests

    @Test("LoadingContent returns localized string")
    func loadingContent_returnsLocalizedString() {
        let expected = localized("loading_content")
        #expect(DynamicListPresenter.loadingContent == expected)
    }

    // MARK: - Error Messages Tests

    @Test("NetworkError returns localized string")
    func networkError_returnsLocalizedString() {
        let expected = localized("network_error")
        #expect(DynamicListPresenter.networkError == expected)
    }

    // MARK: - Error Actions Tests

    @Test("Retry returns localized string")
    func retry_returnsLocalizedString() {
        let expected = localized("retry")
        #expect(DynamicListPresenter.retry == expected)
    }

    // MARK: - Navigation Tests

    @Test("Profile returns localized string")
    func profile_returnsLocalizedString() {
        let expected = localized("profile")
        #expect(DynamicListPresenter.profile == expected)
    }

    @Test("Detail returns localized string")
    func detail_returnsLocalizedString() {
        let expected = localized("detail")
        #expect(DynamicListPresenter.detail == expected)
    }

    @Test("UserDetail returns localized string")
    func userDetail_returnsLocalizedString() {
        let expected = localized("user_detail")
        #expect(DynamicListPresenter.userDetail == expected)
    }

    @Test("ProductDetail returns localized string")
    func productDetail_returnsLocalizedString() {
        let expected = localized("product_detail")
        #expect(DynamicListPresenter.productDetail == expected)
    }

    // MARK: - Content Labels Tests

    @Test("ItemID returns localized string")
    func itemID_returnsLocalizedString() {
        let expected = localized("item_id")
        #expect(DynamicListPresenter.itemID == expected)
    }

    // MARK: - Default Views Tests

    @Test("ItemDetail returns localized string")
    func itemDetail_returnsLocalizedString() {
        let expected = localized("item_detail")
        #expect(DynamicListPresenter.itemDetail == expected)
    }

    @Test("ErrorLoadingData returns localized string")
    func errorLoadingData_returnsLocalizedString() {
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
