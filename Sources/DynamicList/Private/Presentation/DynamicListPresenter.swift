//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// A presenter class that provides localized strings for the DynamicList component
public final class DynamicListPresenter {
    // MARK: - Loading States

    /// Loading content text
    static let loadingContent = NSLocalizedString(
        "loading_content",
        bundle: Bundle.module,
        comment: "Loading content text shown while fetching data",
    )

    /// Loading text
    static let loading = NSLocalizedString(
        "loading",
        bundle: Bundle.module,
        comment: "Loading text for navigation titles",
    )

    // MARK: - Error Messages

    /// Network error message
    static let networkError = NSLocalizedString(
        "network_error",
        bundle: Bundle.module,
        comment: "Network error message when connection fails",
    )

    // MARK: - Error Actions

    /// Retry button text
    static let retry = NSLocalizedString(
        "retry",
        bundle: Bundle.module,
        comment: "Retry button text",
    )

    // MARK: - Navigation

    /// Profile navigation title
    static let profile = NSLocalizedString(
        "profile",
        bundle: Bundle.module,
        comment: "Profile navigation title",
    )

    /// Detail navigation title
    static let detail = NSLocalizedString(
        "detail",
        bundle: Bundle.module,
        comment: "Detail navigation title",
    )

    /// User detail navigation title
    static let userDetail = NSLocalizedString(
        "user_detail",
        bundle: Bundle.module,
        comment: "User detail navigation title",
    )

    /// Product detail navigation title
    static let productDetail = NSLocalizedString(
        "product_detail",
        bundle: Bundle.module,
        comment: "Product detail navigation title",
    )

    /// Error navigation title
    static let error = NSLocalizedString(
        "error",
        bundle: Bundle.module,
        comment: "Error navigation title",
    )

    // MARK: - Content Labels

    /// Item ID label
    static let itemID = NSLocalizedString(
        "item_id",
        bundle: Bundle.module,
        comment: "Item ID label",
    )

    /// ID label with colon
    static let idLabel = NSLocalizedString(
        "id_label",
        bundle: Bundle.module,
        comment: "ID label with colon for item display",
    )

    /// Details text
    static let details = NSLocalizedString(
        "details",
        bundle: Bundle.module,
        comment: "Details text for detail views",
    )

    /// Default search prompt
    public static let searchPrompt = NSLocalizedString(
        "search_prompt",
        bundle: Bundle.module,
        comment: "Default search prompt text",
    )

    // MARK: - Default Views

    /// Default item detail title
    static let itemDetail = NSLocalizedString(
        "item_detail",
        bundle: Bundle.module,
        comment: "Default item detail title",
    )

    /// Default error view title
    static let errorLoadingData = NSLocalizedString(
        "error_loading_data",
        bundle: Bundle.module,
        comment: "Default error view title",
    )
}
