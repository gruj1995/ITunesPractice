//
//  MiniPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/29.
//

import Combine
import Foundation

class MiniPlayerViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var currentTrack: Track? {
        get { musicPlayer.currentTrack }
        set {
            if let currentTrackIndex = tracks.firstIndex(where: { $0 == newValue }) {
                musicPlayer.currentTrackIndex = currentTrackIndex
            }
        }
    }

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        musicPlayer.currentTrackIndexPublisher
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        musicPlayer.isPlayingPublisher
    }

    var tracks: [Track] {
        musicPlayer.playlist
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
