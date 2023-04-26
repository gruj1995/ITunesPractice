//
//  UserDefaults+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/4.
//

import Foundation

extension UserDefaults {
    /// 待播清單
    @UserDefaultValue(key: "toBePlayedTracks", defaultValue: [])
    static var toBePlayedTracks: [Track]

    /// 播放紀錄
    @UserDefaultValue(key: "playedTracks", defaultValue: [])
    static var playedTracks: [Track]

    /// 資料庫清單
    @UserDefaultValue(key: "libraryTracks", defaultValue: [])
    static var libraryTracks: [Track]

    /// 播放器顯示模式
    @UserDefaultValue(key: "playerDisplayMode", defaultValue: .trackInfo)
    static var playerDisplayMode: PlayerDisplayMode
}
