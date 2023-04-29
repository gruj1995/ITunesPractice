//
//  MiniPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/29.
//

import Combine
import Foundation

class MiniPlayerViewModel {
    // MARK: Internal

    var currentTrack: Track? {
        musicPlayer.currentTrack
    }

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        musicPlayer.currentTrackIndexPublisher
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        musicPlayer.isPlayingPublisher
    }

    var isPlaying: Bool {
        get { musicPlayer.isPlaying }
        set { musicPlayer.isPlaying = newValue }
    }

    func next() {
        musicPlayer.nextTrack()
    }

    // MARK: Private

    private let musicPlayer: MusicPlayer = .shared
}
