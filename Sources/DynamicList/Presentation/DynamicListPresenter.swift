//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// A presenter class that provides localized strings for the DynamicList component
public final class DynamicListPresenter {
    // MARK: - Loading States

    /// Loading content text
    public static let loadingContent = NSLocalizedString(
        "loading_content",
        bundle: Bundle.module,
        comment: "Loading content text shown while fetching data",
    )

    /// Loading users text
    public static let loadingUsers = NSLocalizedString(
        "loading_users",
        bundle: Bundle.module,
        comment: "Loading users text shown while fetching users",
    )

    /// Loading products text
    public static let loadingProducts = NSLocalizedString(
        "loading_products",
        bundle: Bundle.module,
        comment: "Loading products text shown while fetching products",
    )

    // MARK: - Error Messages

    /// Network error message
    public static let networkError = NSLocalizedString(
        "network_error",
        bundle: Bundle.module,
        comment: "Network error message when connection fails",
    )

    /// Server error message
    public static let serverError = NSLocalizedString(
        "server_error",
        bundle: Bundle.module,
        comment: "Server error message when backend fails",
    )

    /// Unauthorized access message
    public static let unauthorizedAccess = NSLocalizedString(
        "unauthorized_access",
        bundle: Bundle.module,
        comment: "Unauthorized access error message",
    )

    /// Data corrupted message
    public static let dataCorrupted = NSLocalizedString(
        "data_corrupted",
        bundle: Bundle.module,
        comment: "Data corrupted error message",
    )

    /// Connection timeout message
    public static let connectionTimeout = NSLocalizedString(
        "connection_timeout",
        bundle: Bundle.module,
        comment: "Connection timeout error message",
    )

    // MARK: - Error Actions

    /// Retry button text
    public static let retry = NSLocalizedString(
        "retry",
        bundle: Bundle.module,
        comment: "Retry button text",
    )

    /// Cancel button text
    public static let cancel = NSLocalizedString(
        "cancel",
        bundle: Bundle.module,
        comment: "Cancel button text",
    )

    // MARK: - Navigation

    /// Profile navigation title
    public static let profile = NSLocalizedString(
        "profile",
        bundle: Bundle.module,
        comment: "Profile navigation title",
    )

    /// Detail navigation title
    public static let detail = NSLocalizedString(
        "detail",
        bundle: Bundle.module,
        comment: "Detail navigation title",
    )

    /// User detail navigation title
    public static let userDetail = NSLocalizedString(
        "user_detail",
        bundle: Bundle.module,
        comment: "User detail navigation title",
    )

    /// Product detail navigation title
    public static let productDetail = NSLocalizedString(
        "product_detail",
        bundle: Bundle.module,
        comment: "Product detail navigation title",
    )

    // MARK: - Content Labels

    /// Item ID label
    public static let itemID = NSLocalizedString(
        "item_id",
        bundle: Bundle.module,
        comment: "Item ID label",
    )

    /// Price label
    public static let price = NSLocalizedString(
        "price",
        bundle: Bundle.module,
        comment: "Price label",
    )

    /// Category label
    public static let category = NSLocalizedString(
        "category",
        bundle: Bundle.module,
        comment: "Category label",
    )

    /// Available status
    public static let available = NSLocalizedString(
        "available",
        bundle: Bundle.module,
        comment: "Available status text",
    )

    /// Buy now button text
    public static let buyNow = NSLocalizedString(
        "buy_now",
        bundle: Bundle.module,
        comment: "Buy now button text",
    )

    // MARK: - Error View Titles

    /// Error loading title
    public static let errorLoading = NSLocalizedString(
        "error_loading",
        bundle: Bundle.module,
        comment: "Error loading title",
    )

    // MARK: - Default Views

    /// Default item detail title
    public static let itemDetail = NSLocalizedString(
        "item_detail",
        bundle: Bundle.module,
        comment: "Default item detail title",
    )

    /// Default error view title
    public static let errorLoadingData = NSLocalizedString(
        "error_loading_data",
        bundle: Bundle.module,
        comment: "Default error view title",
    )
}
