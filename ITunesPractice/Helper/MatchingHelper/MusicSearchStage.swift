//
//  MusicSearchStage.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import Foundation

enum MusicSearchStage: CaseIterable {
    case none
    case listening
    case searching
    case expandingSearch
    case challenging
    case finish

    var title: String {
        switch self {
        case .listening: return "聆聽音樂"
        case .searching: return "正在搜尋"
        case .expandingSearch: return "正在擴大搜尋範圍"
        case .challenging: return "這有點難度"
        case .finish: return "無結果"
        case .none: return ""
        }
    }

    var subtitle: String {
        switch self {
        case .listening: return "確認您的裝置可以清楚聽到歌曲"
        case .searching: return "請稍候"
        case .expandingSearch: return "再等我一下"
        case .challenging: return "再試最後一次"
        case .finish: return "未能清楚辨認"
        case .none: return ""
        }
    }
}
