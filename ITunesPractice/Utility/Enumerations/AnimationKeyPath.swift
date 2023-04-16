//
//  AnimationKeyPath.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Foundation

/// CABasicAnimation 的 keyPath 參數
enum AnimationKeyPath: String {
    case opacity // 透明度
    case path // 路徑
    case position
    case transformScale = "transform.scale"
}
