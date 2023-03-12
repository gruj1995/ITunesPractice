//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import Combine

// MARK: - SearchViewModel

class SearchViewModel {
    // MARK: Lifecycle

    init() {

    }

    // MARK: Internal

    var state: ViewState {
        get {
            return stateSubject.value
        }
        set {
            stateSubject.value = newValue
        }
    }

    var statePublisher: AnyPublisher<ViewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // MARK: Private

    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)

    private var currentPage: Int = 0
    private var totalPages: Int = 0
    private var pageSize: Int = 20

    private var cancellables: Set<AnyCancellable> = []
}
