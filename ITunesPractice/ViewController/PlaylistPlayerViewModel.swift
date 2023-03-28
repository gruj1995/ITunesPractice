//
//  PlaylistPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import Foundation
import Combine

class PlaylistPlayerViewModel {
    init() {
  
    }

    // MARK: Internal

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

    var volume: Float {
        get { musicPlayer.volume }
        set { musicPlayer.volume = newValue }
    }

    // 音量下/上限
    let minimumVolume: Float = 0.0
    let maximumVolume: Float = 1.0

    func seek(to time: Double) {
        musicPlayer.seek(to: time)
    }

    // MARK: Private
    private let musicPlayer: MusicPlayer = .shared
    private var cancellables: Set<AnyCancellable> = .init()

    var targetTime: Float = 0

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        return musicPlayer.playbackTimePublisher
    }

    var isPlaying: Bool {
        get { musicPlayer.isPlaying }
        set { musicPlayer.isPlaying = newValue }
    }

    // 當前播放進度（單位：秒）
    var currentTime: Double? {
        musicPlayer.currentPlaybackTime
    }

    // 當前曲目總長度（單位：秒）
    var totalDuration: Double? {
        musicPlayer.currentPlaybackDuration
    }

    // 當前播放進度 Float 值
    var currentTimeFloatValue: Float {
        currentTime?.floatValue ?? 0
    }

    // 當前曲目總長度 Float 值
    var totalDurationFloatValue: Float {
        totalDuration?.floatValue ?? 1
    }
}
