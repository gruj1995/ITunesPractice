//
//  MusicPlayer+Protocols.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import Foundation

// MARK: - MusicPlayerProtocol

protocol MusicPlayerProtocol: MusicPlayerControl, MusicPlayerPlaylistControl, MusicPlayerSpeedControl {}

// MARK: - MusicPlayerControl

protocol MusicPlayerControl {
    var currentPlaybackTime: Double? { get } // 當前播放進度（單位：秒）
    var currentPlaybackDuration: Double? { get } // 當前曲目總長度（單位：秒）
//    var currentPlaybackRemainingTime: Double? { get } // 當前曲目剩餘時間（單位：秒）
    var volume: Float { get set } // 音量大小

    func play() // 從頭開始播放
    func pause() // 暫停
    func resume() // 從暫停的位置繼續播放
    func stop() // 停止播放
    func seek(to time: Double) // 設置播放進度(time 為指定秒數)
}

// MARK: - MusicPlayerPlaylistControl

protocol MusicPlayerPlaylistControl {
    var mainPlaylist: [Track] { get set } // 播放清單
    var currentTrack: Track? { get } // 當前播放曲目（透過currentTrackIndex取得）
    var currentTrackIndex: Int { get set } // 目前選中的曲目的索引
    var isShuffleMode: Bool { get set } // 是否隨機播放
    var repeatMode: RepeatMode { get set } // 重複的模式
    var playbackRate: Float { get set } // 播放速率

    func nextTrack() //  播放清單內的下一首
    func previousTrack()  //  播放清單內的前一首
}

// MARK: - MusicPlayerSpeedControl

protocol MusicPlayerSpeedControl {
    func fastForward() // 快轉
    func rewind() // 倒帶
}
