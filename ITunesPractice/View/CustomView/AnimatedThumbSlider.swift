//
//  AnimatedThumbSlider.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/26.
//

import UIKit

class AnimatedThumbSlider: UISlider {

    private let thumbImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))

    var animateDuration: CGFloat = 0.2
    var thumbScale: CGFloat = 3

    override func awakeFromNib() {
        super.awakeFromNib()
        // 設置初始的 thumb image
        thumbImageView.image = thumbImage(for: .normal)
        addSubview(thumbImageView)

        setThumbImage(AppImages.circleFillTiny, for: .normal)
        setThumbImage(AppImages.circleFillTiny, for: .highlighted)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateThumbPosition()
    }

    // 在布局子視圖時，重新調整 thumbImageView 的位置
    private func updateThumbPosition() {
        let frame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        let center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        thumbImageView.center = center
    }

    func setImage(_ image: UIImage?) {
        thumbImageView.image = image
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 碰觸到 thumbImageView 時(有擴大偵測範圍)，使用動畫將 thumbImageView 放大
            if let touch = touches.first, self.thumbImageView.frame.insetBy(dx: -20.0, dy: -20.0).contains(touch.location(in: self)) {
                UIView.animate(withDuration: self.animateDuration, delay: 0.0, options: .curveLinear, animations: {
                    self.thumbImageView.transform = CGAffineTransform(scaleX: self.thumbScale, y: self.thumbScale)
                }, completion: nil)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 在拖動結束時，使用動畫將 thumbImageView 縮小
            UIView.animate(withDuration: self.animateDuration, delay: 0.0, options: .curveLinear, animations: {
                self.thumbImageView.transform = .identity
            }, completion: nil)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 在拖動取消時，使用動畫將 thumbImageView 縮小
            UIView.animate(withDuration: self.animateDuration, delay: 0.0, options: .curveLinear, animations: {
                self.thumbImageView.transform = .identity
            }, completion: nil)
        }
    }
}

