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
    func play() throws // 從頭開始播放
    func pause() // 暫停
    func resume() // 從暫停的位置繼續播放
    func stop() // 停止播放
}

// MARK: - MusicPlayerPlaylistControl

protocol MusicPlayerPlaylistControl {
    var tracks: [Track] { get }
    func play(track: Track) throws //  播放清單內指定曲目
    func nextTrack() throws //  播放清單內的下一首
    func previousTrack() throws //  播放清單內的前一首
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
