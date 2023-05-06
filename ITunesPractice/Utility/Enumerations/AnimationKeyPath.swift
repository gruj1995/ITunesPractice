//
//  AnimationKeyPath.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Foundation

/// CABasicAnimation 的 keyPath 參數
enum AnimationKeyPath {
    // MARK: 系統的
    static let opacity = "opacity" // 透明度
    static let path = "path" // 路徑
    static let position = "position"
    static let transformScale = "transform.scale"

    // MARK: 自訂的
    static let shazamImageScaleAnimation = "shazamImageScaleAnimation"
    static let rippleGroupAnimation = "rippleGroupAnimation"
    static let pulse = "pulse"
    static let colorsTransition = "colorsTransition"
}
