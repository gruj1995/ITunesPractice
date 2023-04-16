//
//  AudioSearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import Foundation

class AudioSearchViewModel {
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

    func listenMusic() {
        // 開始錄音進行匹配
        matchingHelper.listenMusic()
    }
}
