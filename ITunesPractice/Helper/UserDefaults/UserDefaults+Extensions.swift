//
//  UserDefaults+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/4.
//

import Foundation
import Combine

extension UserDefaults {
    /// 待播清單
    @UserDefaultValue(key: "toBePlayedTracks", defaultValue: [])
    static var toBePlayedTracks: [Track] {
        didSet {
            NotificationCenter.default.post(name: .toBePlayedTracksDidChanged, object: self)
        }
    }

    /// 播放器顯示模式
    @UserDefaultValue(key: "playerDisplayMode", defaultValue: .trackInfo)
    static var playerDisplayMode: PlayerDisplayMode {
        didSet {
            NotificationCenter.default.post(name: .playerDisplayModeDidChanged, object: self)
        }
    }
}
