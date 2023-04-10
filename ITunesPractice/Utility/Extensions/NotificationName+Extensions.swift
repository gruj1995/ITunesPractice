//
//  NotificationName+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/10.
//

import Foundation

// 觀察事件的名稱
extension Notification.Name {
    // 待播清單更新
    static let toBePlayedTracksDidChanged = Notification.Name("toBePlayedTracksDidChanged")
}
