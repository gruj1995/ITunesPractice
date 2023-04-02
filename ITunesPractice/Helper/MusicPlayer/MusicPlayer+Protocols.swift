//
//  MusicPlayer+Protocols.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import Foundation

// MARK: - MusicPlayerProtocol

protocol MusicPlayerProtocol: MusicPlayerControl, MusicPlayerPlaylistControl, MusicPlayerShuffleControl, MusicPlayerRepeatControl, MusicPlayerSpeedControl {}

// MARK: - MusicPlayerControl

protocol MusicPlayerControl {
    var currentPlaybackTime: Double? { get } // 當前播放進度（單位：秒）
    var currentPlaybackDuration: Double? { get } // 當前曲目總長度（單位：秒）
//    var currentPlaybackRemainingTime: Double? { get } // 當前曲目剩餘時間（單位：秒）
    var volume: Float { get set } // 音量大小

    func play()  // 從頭開始播放
    func pause() // 暫停
    func resume() // 從暫停的位置繼續播放
    func stop() // 停止播放
    func seek(to time: Double) // 設置播放進度(time 為指定秒數)
}

// MARK: - MusicPlayerPlaylistControl

protocol MusicPlayerPlaylistControl {
    var tracks: [Track] { get } // 播放清單
    var currentTrack: Track? { get } // 當前播放曲目（透過currentTrackIndex取得）
    var currentTrackIndex: Int? { get } // 目前選中的曲目的索引
    var isShuffleMode: Bool { get set } // 是否隨機播放
    var repeatMode: RepeatMode { get set } // 重複的模式
    var playbackRate: Float { get set } // 播放速率
    var maxPlaybackRate: Float { get } // 播放速率上限
    var minPlaybackRate: Float { get } // 播放速率下限

    func play(track: Track) //  播放清單內指定曲目
    func nextTrack() //  播放清單內的下一首
    func previousTrack() //  播放清單內的前一首
}

// MARK: - MusicPlayerShuffleControl

protocol MusicPlayerShuffleControl {
    func shuffle() //  隨機播放
    func unshuffle() //  依序播放
}

// MARK: - MusicPlayerRepeatControl

protocol MusicPlayerRepeatControl {
    func repeatOne() //  單曲循環，當播放到最後一首歌時回到第一首歌循環播放
    func repeatAll() //  列表循環，當播放到最後一首歌時回到第一首歌循環播放
    func repeatNone() //  不重複播放，當播放到最後一首歌時停止播放
}

// MARK: - MusicPlayerSpeedControl

protocol MusicPlayerSpeedControl {
    func fastForward() // 快轉
    func rewind() // 倒帶
}
