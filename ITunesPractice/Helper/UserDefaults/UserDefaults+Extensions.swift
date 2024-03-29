//
//  UserDefaults+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/4.
//

import Foundation

extension UserDefaults {
    // MARK: - 資料相關

    /// 所有播放清單
    @UserDefaultValue(key: "playlists", defaultValue: [])
    static var playlists: [Playlist]

    /// 儲存所有歌曲的預設播放清單
    @UserDefaultValue(key: "defaultPlaylist", defaultValue: Playlist(id: 1, name: "所有歌曲", description: "", tracks: []))
    static var defaultPlaylist: Playlist

    /// 自動增加的 Track id
    @UserDefaultValue(key: "autoIncrementTrackID", defaultValue: 0)
    static var autoIncrementTrackID: Int

    /// 自動增加的 Playlist id
    @UserDefaultValue(key: "autoIncrementPlaylistID", defaultValue: 0)
    static var autoIncrementPlaylistID: Int

    /// 主音樂清單(包含所有加入過的音樂)
    @UserDefaultValue(key: "mainPlaylist", defaultValue: [])
    static var mainPlaylist: [Track]

    /// 選中的主音樂清單索引
    @UserDefaultValue(key: "currentTrackIndex", defaultValue: 0)
    static var currentTrackIndex: Int

    /// 選中的隨機待播清單索引
    @UserDefaultValue(key: "currentShuffleTrackIndex", defaultValue: 0)
    static var currentShuffleTrackIndex: Int

    /// 顯示的待播清單索引陣列
    @UserDefaultValue(key: "orderedIndices", defaultValue: [])
    static var orderedIndices: [Int]

    /// 顯示的隨機待播清單索引陣列
    @UserDefaultValue(key: "shuffledIndices", defaultValue: [])
    static var shuffledIndices: [Int]

    /// 完整的隨機待播清單索引陣列
    @UserDefaultValue(key: "entireShuffledIndices", defaultValue: [])
    static var entireShuffledIndices: [Int]

    /// 播放紀錄
    @UserDefaultValue(key: "playedTracks", defaultValue: [])
    static var playedTracks: [Track]

    /// 預設貓貓圖的路徑陣列
    @UserDefaultValue(key: "placeholderUrls", defaultValue: [])
    static var placeholderUrls: [URL]

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

    // MARK: Shazam

    /// 搜尋到的音樂
    @UserDefaultValue(key: "shazamSearchRecords", defaultValue: [])
    static var shazamSearchRecords: [Track]
}
