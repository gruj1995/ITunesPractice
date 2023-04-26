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

    init(track: Track) {
        self.track = track
        self.hasVideo = track.videoUrl != nil
    }

    // MARK: Internal

    private(set) var track: Track

    let hasVideo: Bool

    // MARK: Private

    private let matchingHelper = MatchingHelper.shared
}
