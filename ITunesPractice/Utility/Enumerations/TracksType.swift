//
//  TracksType.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/27.
//

import Foundation

enum TracksType {
    case history
    case playlist
    case library

    var title: String {
        switch self {
        case .history: return "播放紀錄"
        case .playlist: return "待播清單"
        case .library: return "資料庫清單"
        }
    }
}
