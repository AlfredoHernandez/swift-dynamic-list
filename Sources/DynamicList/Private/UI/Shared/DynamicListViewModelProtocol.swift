//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CombineSchedulers
import Foundation

/// Protocol that defines the common interface for dynamic list view models
protocol DynamicListViewModelProtocol: Observable {
    associatedtype Item: Identifiable & Hashable
    associatedtype ViewState: DynamicListViewStateProtocol where ViewState.Item == Item

    /// The current view state
    var viewState: ViewState { get }

    /// Current search text
    var searchText: String { get set }

    /// Sets the search configuration
    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?)

    /// Loads data
    func loadData()

    /// Refreshes the data
    func refresh()

    /// Perform search
    func search(query: String)
}

// MARK: - Type Erased Wrapper

/// Type-erased wrapper for DynamicListViewModelProtocol
struct AnyDynamicListViewModel<Item: Identifiable & Hashable>: Observable {
    private let _viewState: () -> any DynamicListViewStateProtocol
    private let _searchText: () -> String
    private let _setSearchText: (String) -> Void
    private let _setSearchConfiguration: (SearchConfiguration<Item>?) -> Void
    private let _loadData: () -> Void
    private let _refresh: () -> Void
    private let _search: (String) -> Void

    var viewState: any DynamicListViewStateProtocol { _viewState() }
    var searchText: String {
        get { _searchText() }
        set { _setSearchText(newValue) }
    }

    init<V: DynamicListViewModelProtocol>(_ viewModel: V) where V.Item == Item {
        var capturedViewModel = viewModel
        _viewState = { capturedViewModel.viewState }
        _searchText = { capturedViewModel.searchText }
        _setSearchText = { capturedViewModel.searchText = $0 }
        _setSearchConfiguration = { capturedViewModel.setSearchConfiguration($0) }
        _loadData = { capturedViewModel.loadData() }
        _refresh = { capturedViewModel.refresh() }
        _search = { capturedViewModel.search(query: $0) }
    }

    func setSearchConfiguration(_ configuration: SearchConfiguration<Item>?) {
        _setSearchConfiguration(configuration)
    }

    func loadData() {
        _loadData()
    }

    func refresh() {
        _refresh()
    }

    func search(query: String) {
        _search(query)
    }
}
