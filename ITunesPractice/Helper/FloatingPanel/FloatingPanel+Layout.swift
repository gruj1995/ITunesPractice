//
//  FloatingPanel+Layout.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/18.
//

import FloatingPanel
import UIKit

// MARK: - FPLayoutType

enum FPLayoutType {
    case modalFullScreen
    case miniBar

    // MARK: Internal

    var layout: FloatingPanelLayout {
        switch self {
        case .modalFullScreen:
            return ModalFullScreenPanelLayout()
        case .miniBar:
            return MiniBarPanelLayout()
        }
    }
}

// MARK: - ModalFullScreenPanelLayout

/**
    套件作者展示了一些 Layout 的設置搭配
    https://github.com/scenee/FloatingPanel/blob/2.4.1/Examples/Samples/Sources/Layouts.swift#L40
 */

/// 2023/3/18 自己添加的 full screen 樣式
class ModalFullScreenPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full

    // 各個錨點在螢幕上的位置
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview)
//            .hidden: FloatingPanelLayoutAnchor(absoluteInset: 10, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    // 預設 state == .full ? 0.3 : 0.0
    // 如果alpha為0則背景遮罩會消失
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}

/// 2023/5/6 自己添加的底部樣式
class MiniBarPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip

    // 各個錨點在螢幕上的位置
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    // 預設 state == .full ? 0.3 : 0.0
    // 如果alpha為0則背景遮罩會消失
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}

// MARK: - TopPositionedPanelLayout

class TopPositionedPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .top
    let initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 88.0, edge: .bottom, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 216.0, edge: .top, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .top, referenceGuide: .safeArea)
        ]
    }
}

// MARK: - IntrinsicPanelLayout

class IntrinsicPanelLayout: FloatingPanelBottomLayout {
    override var initialState: FloatingPanelState { .full }
    override var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .safeArea)
        ]
    }
}

// MARK: - RemovablePanelLayout

class RemovablePanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 130.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}

// MARK: - RemovablePanelLandscapeLayout

class RemovablePanelLandscapeLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 216.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}

// MARK: - ModalPanelLayout

class ModalPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelIntrinsicLayoutAnchor(absoluteOffset: 0.0, referenceGuide: .safeArea)
        ]
    }

    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}
