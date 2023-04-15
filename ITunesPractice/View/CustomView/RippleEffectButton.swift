//
//  RippleEffectButton.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

// MARK: - RippleEffectButton

// 點擊會產生水波紋動畫的按鈕
class RippleEffectButton: UIButton {
    // MARK: Lifecycle

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Internal

    var longPressAction: ((Bool) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.frame = bounds
        updatePath()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showCircleLayer()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hideCircleLayer()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        // 避免觸發長按手勢時隱藏 circleLayer
        if !isLongPressActive {
            hideCircleLayer()
        }
    }

    // MARK: Private

    // 圓圈圖層
    private lazy var circleLayer: CAShapeLayer = {
        let sLayer = CAShapeLayer()
        sLayer.fillColor = UIColor(white: 1, alpha: 0.15).cgColor
        sLayer.opacity = 0
        return sLayer
    }()

    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 認定為長按手勢的最短時間
        longPressGesture.allowableMovement = 10 // 允許移動的最大距離
        return longPressGesture
    }()

    private var isCircleLayerHidden = true {
        didSet {
            circleLayer.opacity = isCircleLayerHidden ? 0 : 1
        }
    }

    // 長按手勢是否正在進行
    private var isLongPressActive: Bool = false

    private func setup() {
        layer.addSublayer(circleLayer)
        addGestureRecognizer(longPressGesture)
        clipsToBounds = false
    }

    /// 更新圓圈圖層位址
    private func updatePath() {
        let diameter = min(bounds.width, bounds.height)
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        circleLayer.path = UIBezierPath(arcCenter: arcCenter, radius: diameter / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
    }

    private func showCircleLayer() {
        isCircleLayerHidden = false
    }

    /// 顯示波紋動畫，顯示完移除動畫圖層
    private func hideCircleLayer() {
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        // 動畫持續時間
        let rippleAnimationDuration = 0.3
        // 起始圓圈半徑
        let startRadius = bounds.height * 0.5
        // 結束圓圈半徑
        let endRadius = startRadius + 4
        // 結束角度設為圓形
        let endAngle: CGFloat = 2 * .pi

        // Create paths for out start and end circles.
        let startPath = UIBezierPath(arcCenter: arcCenter, radius: startRadius, startAngle: 0, endAngle: endAngle, clockwise: true)
        let endPath = UIBezierPath(arcCenter: arcCenter, radius: endRadius, startAngle: 0, endAngle: endAngle, clockwise: true)

        /*
            在 CAAnimationGroup 中的每個動畫（即 animations 數組中的每個動畫）都是獨立的 CAAnimation 對象，
            其 isRemovedOnCompletion 屬性的值優先於 CAAnimationGroup 的屬性值
         */

        // 調整路徑，實現波紋動畫
        let pathAnimation = CABasicAnimation(keyPath: AnimationKeyPath.path.rawValue)
        pathAnimation.fromValue = startPath.cgPath
        pathAnimation.toValue = endPath.cgPath

        // 調整透明度，實現淡出動畫
        let opacityAnimation = CABasicAnimation(keyPath: AnimationKeyPath.opacity.rawValue)
        opacityAnimation.duration = rippleAnimationDuration
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        // CAAnimationGroup 可以讓多個動畫同時執行，並在它們結束後可以一次性移除所有的動畫
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [pathAnimation, opacityAnimation]
        groupAnimation.duration = rippleAnimationDuration
        // 動畫完成後自動從圖層移除
        groupAnimation.isRemovedOnCompletion = false
        // 參考文章說明 https://juejin.cn/post/6991371790245183496
        groupAnimation.fillMode = .forwards
        circleLayer.add(groupAnimation, forKey: "RippleGroupAnimation")

        // 等動畫結束隱藏 circleLayer
        DispatchQueue.main.asyncAfter(deadline: .now() + rippleAnimationDuration) {
            // All animations are done, so remove the layer.
            self.circleLayer.removeAllAnimations()
            self.isCircleLayerHidden = true
        }
    }

    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        isLongPressActive = gesture.state == .began
        if !isLongPressActive {
            hideCircleLayer()
        }
        longPressAction?(!isLongPressActive)
    }
}
