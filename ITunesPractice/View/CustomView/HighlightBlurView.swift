//
//  HighlightBlurView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/15.
//

import SnapKit
import UIKit

/// 模仿原生元件 highlight 效果，並且背景為毛玻璃效果
class HighlightBlurView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        addBlurView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveLinear, animations: {
                self.blurView.effect = self.lightBlurEffect
            }, completion: nil)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveEaseOut, animations: {
                self.blurView.effect = self.darkBlurEffect
            }, completion: nil)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveEaseOut, animations: {
                self.blurView.effect = self.darkBlurEffect
            }, completion: nil)
        }
    }

    // MARK: Private

    // 以下這兩種效果比較接近原生的
    private let darkBlurEffect = UIBlurEffect(style: .systemMaterialDark)
    private let lightBlurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)

    // 毛玻璃view
    private lazy var blurView: UIVisualEffectView = .init(effect: darkBlurEffect)

    private let duration: CGFloat = 0.3

    private func addBlurView() {
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
