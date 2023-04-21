//
//  PulsingLayer.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/20.
//

import UIKit

// 參考自： https://github.com/brianadvent/CoolCoreAnimations/blob/master/CoreAnimation/ViewController.swift

class Pulsing: CALayer {
    // MARK: Lifecycle

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(radius: CGFloat, position: CGPoint, animationDuration: TimeInterval, color: UIColor?, targetScale: Float, initialScale: Float = 1, numberOfPulses: Float = 1) {
        super.init()

        self.radius = radius
        self.initialPulseScale = initialScale
        self.targetPulseScale = targetScale
        self.animationDuration = animationDuration
        self.numberOfPulses = numberOfPulses

        opacity = 0
        backgroundColor = color?.cgColor
        cornerRadius = radius
        bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        self.position = position

        setupAnimationGroup()

        DispatchQueue.main.async {
            self.add(self.animationGroup, forKey: AnimationKeyPath.pulse)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.removeFromSuperlayer()
        }
    }

    // MARK: Private

    private var animationGroup = CAAnimationGroup()
    private var initialPulseScale: Float = 1
    private var targetPulseScale: Float = 1
    private var animationDuration: TimeInterval = 1
    private var radius: CGFloat = 0
    private var numberOfPulses: Float = 1 // 動畫次數
    private var nextPulseAfter: TimeInterval = 0

    /// 縮放動畫
    private func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: AnimationKeyPath.transformScale)
        scaleAnimation.fromValue = NSNumber(value: initialPulseScale)
        scaleAnimation.toValue = NSNumber(value: targetPulseScale)
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }

    /// 透明度動畫
    private func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: AnimationKeyPath.opacity)
        opacityAnimation.duration = animationDuration
        // 透明度變化
        opacityAnimation.values = [0.4, 0.8, 0]
        // 0 ~ 1 為時間比例，0.2 代表進行到 20%
        opacityAnimation.keyTimes = [0, 0.2, 1]
        return opacityAnimation
    }

    private func setupAnimationGroup() {
        animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration + nextPulseAfter
        animationGroup.repeatCount = numberOfPulses

        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationGroup.timingFunction = timingFunction

        animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    }
}
