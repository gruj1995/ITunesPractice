//
//  Utils.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import UIKit

struct Utils {
    /// 獲取App的根目錄路徑
    static func applicationSupportDirectoryPath() -> String {
        NSHomeDirectory()
    }

    /// 顯示 toast
    /// - Parameters:
    ///  - msg: toast message
    ///  - position: 出現位置
    ///  - textAlignment: 文字對齊方式
    static func toast(_ msg: String, at position: ToastHelper.Position = .bottom, alignment: NSTextAlignment = .center) {
        ToastHelper.shared.showToast(text: msg, position: position, alignment: alignment)
    }

    // TODO: 移位置
    // 測試用
    static func addTracksToUserDefaults(_ tracks: [Track]) {
        var storedTracks = UserDefaults.standard.tracks
        storedTracks.appendIfNotContains(tracks)
        UserDefaults.standard.tracks = storedTracks
    }

    // 測試用
    static func addTrackToUserDefaults(_ track: Track) {
        var storedTracks = UserDefaults.standard.tracks
        storedTracks.appendIfNotContains(track)
        UserDefaults.standard.tracks = storedTracks
    }
}
