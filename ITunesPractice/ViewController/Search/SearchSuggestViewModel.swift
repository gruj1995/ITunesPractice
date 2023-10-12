//
//  SearchSuggestViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/11.
//

import Combine
import Foundation

class SearchSuggestViewModel {

    init() {
        $searchTerm
            .debounce(for: 0.5, scheduler: RunLoop.main) // 延遲觸發搜索操作(0.5s)
            .removeDuplicates() // 避免在使用者輸入相同的搜索文字時重複執行搜索操作
            .sink { [weak self] term in
                self?.search(with: term)
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var searchTerm: String = ""
    @Published var state: ViewState = .none

    var totalCount: Int {
        items.count
    }

    func loadNextPage() {
        guard !searchTerm.isEmpty else {
            filteredHistoryItems = historyItems
            items = filteredHistoryItems
            state = .success
            return
        }

        // 避免同時載入多次
        if case .loading = state { return }
        state = .loading

        NetworkManager.shared.fetchYTAutoSuggest(term: searchTerm) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.filteredHistoryItems = self.historyItems.filter { $0.contains(self.searchTerm) }
                self.items = filteredHistoryItems + items
                DispatchQueue.main.async {
                    self.state = .success
                }
            case .failure(let error):
                Logger.log(error.localizedDescription)
                DispatchQueue.main.async {
                    self.state = .failed(error: error)
                }
            }
        }
    }

    func setSelectedItem(forCellAt index: Int) {
        selectedItem = items[safe: index]

        guard let selectedItem else { return }
        if let index = historyItems.firstIndex(of: selectedItem) {
            historyItems.remove(at: index)
        }
        historyItems.insert(selectedItem, at: 0)
    }

    func reloadTracks() {
        items.removeAll()
        loadNextPage()
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()
    private(set) var items: [String] = []
    private(set) var selectedItem: String?
    var historyItems: [String] {
        get { UserDefaults.historyItems }
        set { UserDefaults.historyItems = newValue }
    }
    var filteredHistoryItems: [String] = []

    private func search(with term: String) {
        searchTerm = term
        reloadTracks()
    }
}
