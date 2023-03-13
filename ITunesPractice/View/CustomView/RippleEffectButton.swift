//
//  RippleEffectButton.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

// 點擊會產生水波紋動畫的按鈕
class RippleEffectButton: UIButton {
    // MARK: Internal

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.showRippleEffect()
    }

    // MARK: Private

    private func showRippleEffect() {
        let origin = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let color = UIColor(white: 1, alpha: 0.15)
        let duration = 0.2
        let radius = self.bounds.height / 2
        let fadeAfter = duration * 0.9
        self.rippleStarting(at: origin, withColor: color, duration: duration, radius: radius, fadeAfter: fadeAfter)
    }
}
