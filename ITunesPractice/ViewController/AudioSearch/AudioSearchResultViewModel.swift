//
//  AudioSearchResultViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import Combine
import Foundation

class AudioSearchResultViewModel {

    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var track: Track?

    let matchingHelper = MatchingHelper.shared

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    var trackPublisher: AnyPublisher<Track?, Never> {
        matchingHelper.trackPublisher
    }
}
