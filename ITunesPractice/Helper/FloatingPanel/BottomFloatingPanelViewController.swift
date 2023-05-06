//
//  BottomFloatingPanelViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/6.
//

import FloatingPanel
import UIKit

// MARK: - BottomFloatingPanelViewController

class BottomFloatingPanelViewController: UIViewController {
    /// 可設置錨點的容器
    func getFpc() -> FloatingPanelController {
        let fpc = FloatingPanelController()
        fpc.delegate = self
        // 隱藏頂部拖動指示器
        fpc.surfaceView.grabberHandle.isHidden = false

        // 頂部 grabber view 與邊緣的距離
        fpc.surfaceView.grabberHandlePadding = 40

        fpc.surfaceView.backgroundColor = .clear

        // 是否允許下滑時關閉頁面
        fpc.isRemovalInteractionEnabled = false

        fpc.behavior = DisableBouncePanelBehavior()

        fpc.layout = FPLayoutType.miniBar.layout
        fpc.invalidateLayout()

        // 容器內容頁填充容器的模式
        //        fpc.contentMode = .fitToBounds

        return fpc
    }
}

// MARK: FloatingPanelControllerDelegate

extension BottomFloatingPanelViewController: FloatingPanelControllerDelegate {
    /// 頁面關閉條件
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        // 低於頁面一半或下滑超過一定速度時
//        return location.y > Constants.screenHeight / 2 || velocity.dy > 1.5
        return false
    }

    func floatingPanel(_ fpc: FloatingPanelController, animatorForPresentingTo state: FloatingPanelState) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.3, curve: .easeIn)
    }

    func floatingPanel(_ fpc: FloatingPanelController, animatorForDismissingWith velocity: CGVector) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
    }

    /**
     當浮動面板移動時，會檢查是否正在執行吸引動畫（attracting），如果沒有正在執行吸引動畫，則獲取浮動面板在全屏模式下的最小和最大 y 坐標值（即最頂部和最底部），然後將浮動面板的位置限制在這個範圍內。
     */
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if !fpc.isAttracting {
            let loc = fpc.surfaceLocation
            let minY = fpc.surfaceLocation(for: .full).y
            let maxY = fpc.surfaceLocation(for: .hidden).y
            fpc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }
    }
}
