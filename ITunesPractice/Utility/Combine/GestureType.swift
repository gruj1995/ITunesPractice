//
//  GestureType.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/14.
//

import UIKit

// MARK: - GestureType

enum GestureType {
    case tap(UITapGestureRecognizer = .init()) // 點擊
    case swipe(UISwipeGestureRecognizer = .init())  // 滑動
    case longPress(UILongPressGestureRecognizer = .init())  // 長按
    case pan(UIPanGestureRecognizer = .init())  // 拖曳
    case pinch(UIPinchGestureRecognizer = .init()) // 捏合 (兩指)
    case edge(UIScreenEdgePanGestureRecognizer = .init()) // 從螢幕邊緣滑動

    // MARK: Internal

    func get() -> UIGestureRecognizer {
        switch self {
        case let .tap(tapGesture):
            return tapGesture
        case let .swipe(swipeGesture):
            return swipeGesture
        case let .longPress(longPressGesture):
            return longPressGesture
        case let .pan(panGesture):
            return panGesture
        case let .pinch(pinchGesture):
            return pinchGesture
        case let .edge(edgePanGesture):
            return edgePanGesture
        }
    }
}
