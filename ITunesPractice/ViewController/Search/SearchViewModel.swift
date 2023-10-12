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

    // MARK: Private

    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)
    private var state: ViewState {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }
    private var cancellables: Set<AnyCancellable> = .init()
}
