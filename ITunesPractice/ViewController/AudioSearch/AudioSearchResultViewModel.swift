//
//  AudioSearchResultViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import Combine
import UIKit

class AudioSearchResultViewModel {
    // MARK: Lifecycle

    init(track: Track) {
        self.track = track
        self.hasVideo = track.videoUrl != nil
    }

    // MARK: Internal

    private(set) var track: Track

    let hasVideo: Bool

    var randomBgColor: UIColor? {
        colors.randomElement()
    }

    // MARK: Private

    private let matchingHelper = MatchingHelper.shared

    private let colors: [UIColor] = [
        UIColor(hex: "#F97B22"), // 橘
        UIColor(hex: "#FEE8B0"), // 淡黃
        UIColor(hex: "#9CA777"), // 橄欖綠
        UIColor(hex: "#7C9070"), // 深橄欖綠
        UIColor(hex: "#E76161"), // 洋紅
        UIColor(hex: "#B04759"), // 紅紫
        UIColor(hex: "#19A7CE"), // 藍
        UIColor(hex: "#146C94") // 深藍
    ]
}
