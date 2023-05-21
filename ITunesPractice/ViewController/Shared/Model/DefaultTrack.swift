//
//  DefaultTrack.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/2.
//

import UIKit

// 沒有選中曲目時的預設圖片與文字
struct DefaultTrack {
    static let coverImage = AppImages.musicNote
    static let trackName = "未在播放"
    static let gradientColors: [UIColor] = [.systemGray, .gray, .darkGray]
}
