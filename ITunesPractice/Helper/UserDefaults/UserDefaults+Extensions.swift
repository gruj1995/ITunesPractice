//
//  UserDefaults+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/4.
//

import Foundation

extension UserDefaults {
    // MARK: - 資料相關

    /// 主音樂清單(包含所有加入過的音樂)
    @UserDefaultValue(key: "mainPlaylist", defaultValue: [])
    static var mainPlaylist: [Track]

    /// 選中的主音樂清單索引
    @UserDefaultValue(key: "currentTrackIndex", defaultValue: 0)
    static var currentTrackIndex: Int

    /// 顯示用的待播清單索引陣列
    @UserDefaultValue(key: "displayIndices", defaultValue: [])
    static var displayIndices: [Int]

    /// 亂序的待播清單索引陣列
    @UserDefaultValue(key: "shuffledDisplayIndices", defaultValue: [])
    static var shuffledDisplayIndices: [Int]

    /// 播放紀錄
    @UserDefaultValue(key: "playedTracks", defaultValue: [])
    static var playedTracks: [Track]

    /// 資料庫清單
    @UserDefaultValue(key: "libraryTracks", defaultValue: [])
    static var libraryTracks: [Track]

    // MARK: - 播放清單頁

    /// 播放器顯示模式
    @UserDefaultValue(key: "playerDisplayMode", defaultValue: .trackInfo)
    static var playerDisplayMode: PlayerDisplayMode

    /// 是否隨機播放
    @UserDefaultValue(key: "isShuffleMode", defaultValue: false)
    static var isShuffleMode: Bool

    /// 重複播放的模式
    @UserDefaultValue(key: "repeatMode", defaultValue: .none)
    static var repeatMode: RepeatMode

    /// 是否無限循環
    @UserDefaultValue(key: "isInfinityMode", defaultValue: false)
    static var isInfinityMode: Bool
}
