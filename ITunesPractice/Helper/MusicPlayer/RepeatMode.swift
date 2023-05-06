//
//  RepeatMode.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/25.
//

import UIKit

// MARK: - RepeatMode

enum RepeatMode: CaseIterable, Codable {
    case none // 不重複播放，當播放到最後一首歌時停止播放
    case all // 列表循環，當播放到最後一首歌時回到第一首歌循環播放
    case one // 單曲循環，當播放到最後一首歌時回到第一首歌循環播放

    var image: UIImage? {
        switch self {
        case .one: return AppImages.repeat1
        default: return AppImages.repeat0
        }
    }
}
