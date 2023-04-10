//
//  UIView+Ripple.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/14.
//

import UIKit

extension UIView {
    // 參考文章 https://maurodec.com/blog/simple-ripple-effect-for-ios-views/
    /// 點擊產生水波紋效果
    func rippleStarting(at origin: CGPoint, withColor color: UIColor, duration: TimeInterval, radius: CGFloat, fadeAfter: TimeInterval) {
        let full: CGFloat = 2 * .pi
        let rippleLayerName = "RippleLayer"

        func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            return sqrt(pow(abs(a.x - b.x), 2) + pow(abs(a.y - b.y), 2))
        }

        let bounds = self.bounds
        let x = bounds.width
        let y = bounds.height

        // Build an array with the four corners of the view.
        let corners: [NSValue] = [NSValue(cgPoint: CGPoint(x: 0, y: 0)),
                                  NSValue(cgPoint: CGPoint(x: 0, y: y)),
                                  NSValue(cgPoint: CGPoint(x: x, y: 0)),
                                  NSValue(cgPoint: CGPoint(x: x, y: y))]

        // Calculate the corner closest to the origin and the one farther from it.
        // We might not need these values, but calculate them anyway so that the code
        // is clearer.
        var minDistance = CGFloat.greatestFiniteMagnitude
        var maxDistance: CGFloat = -1

        for cornerValue in corners {
            let corner = cornerValue.cgPointValue
            let d = distanceBetween(origin, corner)
            if d < minDistance {
                minDistance = d
            }

            if d > maxDistance {
                maxDistance = d
            }
        }

        // Calculate the start and end radius of our ripple effect.
        // If the ripple starts inside the view then the start radius is 0, if it
        // starts outside the view then make the radius the distance to the nearest corner.
        let originInside = origin.x > 0 && origin.x < x && origin.y > 0 && origin.y < y

        // Note that if 0 is used as a default value then the circle may look misshapen.
//        let startRadius = originInside ? 0.1 : minDistance

        // MARK: 這邊修改原本作者的寫法，不要讓動畫從中間開始，而是靠外邊一點開始，比較接近apple按鈕動畫

        let startRadius = radius - 2

        // If we set a radius use it, if not then use the distance to the farthest corner.
        let endRadius = radius > 0 ? radius : minDistance

        // Create paths for out start and end circles.
        let startPath = UIBezierPath(arcCenter: origin, radius: startRadius, startAngle: 0, endAngle: full, clockwise: true)
        let endPath = UIBezierPath(arcCenter: origin, radius: endRadius, startAngle: 0, endAngle: full, clockwise: true)

        // Create a new layer to draw the ripple on.
        let rippleLayer = CAShapeLayer()
        rippleLayer.name = rippleLayerName
        // Make sure the ripple effect doesn't "leave" the view.
        self.layer.masksToBounds = true

        rippleLayer.fillColor = color.cgColor

        // Create the animation
        let rippleAnimation = CABasicAnimation(keyPath: "path")
        rippleAnimation.fillMode = .both
        rippleAnimation.duration = duration
        rippleAnimation.fromValue = startPath.cgPath
        rippleAnimation.toValue = endPath.cgPath
        rippleAnimation.isRemovedOnCompletion = false
        rippleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        // Set the ripple layer to be just above the bg.
        self.layer.insertSublayer(rippleLayer, at: 0)
        // Give the ripple layer the animation.
        rippleLayer.add(rippleAnimation, forKey: nil)

        // Enqueue blocks to handle animation ends.
        // We can use a delegate for this, but it complicates the code as handling
        // animation states is needed as well as @propertys to pass data around.
        // This may not be perfectly times but it is good enough.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + fadeAfter) {
            // Add a fade out animation.
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fillMode = CAMediaTimingFillMode.both
            fadeAnimation.duration = duration - fadeAfter
            fadeAnimation.fromValue = 1.0
            fadeAnimation.toValue = 0.0
            fadeAnimation.isRemovedOnCompletion = false

            rippleLayer.add(fadeAnimation, forKey: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            // All animations are done, so remove the layer.
            rippleLayer.removeAllAnimations()
            rippleLayer.removeFromSuperlayer()
        }
    }
}
