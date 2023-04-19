//
//  CircleButton.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import UIKit

class CircleButton: UIButton {
    // MARK: Lifecycle

    init(backgroundAlpha: CGFloat = 0.1) {
        self.backgroundAlpha = backgroundAlpha
        super.init(frame: .zero)

        backgroundColor = .clear
        layer.addSublayer(backgroundLayer)

        layoutSubviews()
    }

    private let backgroundAlpha: CGFloat

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = bounds.height * 0.5
        backgroundLayer.backgroundColor = UIColor(white: 1, alpha: backgroundAlpha).cgColor

        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
    }

    // MARK: Private

    private let backgroundLayer = CALayer()
}
