//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import Combine
import Foundation

// MARK: - SearchViewModel

class SearchViewModel {

    // MARK: Internal

    var statePublisher: AnyPublisher<ViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func updateHistoryItems(term: String?) {
        guard let term else { return }
        if let index = UserDefaults.historyItems.firstIndex(of: term) {
            UserDefaults.historyItems.remove(at: index)
        }
        UserDefaults.historyItems.insert(term, at: 0)
    }

    // MARK: Private

    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)
    private var state: ViewState {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }
    private var cancellables: Set<AnyCancellable> = .init()
}
