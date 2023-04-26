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

    /// 播放器顯示模式
    @UserDefaultValue(key: "playerDisplayMode", defaultValue: .trackInfo)
    static var playerDisplayMode: PlayerDisplayMode
}
