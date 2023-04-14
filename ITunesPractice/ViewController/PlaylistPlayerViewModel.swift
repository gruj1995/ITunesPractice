//
//  PlaylistPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import Combine
import Foundation

// MARK: - SliderUpdateType

enum SliderUpdateType {
    case automatic // 自動更新
    case manual // 手動更新
}

// MARK: - PlaylistPlayerViewModel

class PlaylistPlayerViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    // 當前播放進度（單位：秒）
    @FormattedTime var displayedCurrentTime: Float?

    // 剩餘播放進度（單位：秒）
    @FormattedTime var displayedRemainingTime: Float?

    // 當前的播放進度百分比 (0~1)
    var playbackPercentage: Float {
        currentTimeFloatValue / totalDurationFloatValue
    }

    // 用戶拖動 slider 後新的播放進度百分比
    var newPlaybackPercentage: Float = 0 {
        didSet {
            updateDisplayedTime(type: .manual)
        }
    }

    var volume: Float {
        get { musicPlayer.volume }
        set { musicPlayer.volume = newValue }
    }

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        musicPlayer.playbackTimePublisher
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        musicPlayer.isPlayingPublisher
    }

    var isPlaying: Bool {
        get { musicPlayer.isPlaying }
        set { musicPlayer.isPlaying = newValue }
    }

    // 當前曲目總長度（單位：秒）
    var totalDuration: Double? {
        musicPlayer.currentPlaybackDuration
    }

    // 當前播放進度 Float 值
    var currentTimeFloatValue: Float {
        musicPlayer.currentPlaybackTime?.floatValue ?? 0
    }

    // 當前曲目總長度 Float 值
    var totalDurationFloatValue: Float {
        musicPlayer.currentPlaybackDuration?.floatValue ?? 1
    }

    func updateDisplayedTime(type: SliderUpdateType) {
        if let totalDuration = totalDuration?.floatValue {
            let newPercentage = type == .automatic ? playbackPercentage : newPlaybackPercentage
            let newCurrentTime = newPercentage * totalDuration
            displayedCurrentTime = newCurrentTime
            displayedRemainingTime = -totalDuration + newCurrentTime
        } else {
            displayedCurrentTime = nil
            displayedRemainingTime = nil
        }
    }

    func next() {
        musicPlayer.nextTrack()
    }

    func previous() {
        musicPlayer.previousTrack()
    }

    func seekToNewTime() {
        let time = Double(newPlaybackPercentage * totalDurationFloatValue)
        musicPlayer.seek(to: time)
    }

    // MARK: Private

    private let musicPlayer: MusicPlayer = .shared
    private var cancellables: Set<AnyCancellable> = .init()
}
