//
//  PlaylistPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import Combine
import Foundation

class PlaylistPlayerViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    /// 新拖動的播放進度百分比 (0~1)
    var newPlaybackPercentage: Float = 0

    /// 播放進度百分比 (0~1)
    var playbackPercentage: Float {
        currentTimeFloatValue / totalDurationFloatValue
    }

    var currentTime: Double? {
        get {
            musicPlayer.currentPlaybackTime
        }
        set {
            musicPlayer.currentPlaybackTime = newValue
        }
    }

    // 當前播放進度（單位：秒）
    @FormattedTime var displayedCurrentTime: Float?
    // 剩餘播放進度（單位：秒）
    @FormattedTime var displayedRemainingTime: Float?

    var volume: Float {
        get { musicPlayer.volume }
        set { musicPlayer.volume = newValue }
    }

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        return musicPlayer.playbackTimePublisher
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

    func updateDisplayedTime() {
        if let totalDuration = totalDuration?.floatValue {
            let newCurrentTime = playbackPercentage * totalDuration
            displayedCurrentTime = newCurrentTime
            displayedRemainingTime = -totalDuration + newCurrentTime
        } else {
            displayedCurrentTime = nil
            displayedRemainingTime = nil
        }
    }

    // 當前曲目總長度 Float 值
    var totalDurationFloatValue: Float {
        musicPlayer.currentPlaybackDuration?.floatValue ?? 1
    }

    func play() {
        musicPlayer.play()
    }

    func pause() {
        musicPlayer.pause()
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
