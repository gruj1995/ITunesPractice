//
//  CircleButton.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import UIKit

class CircleButton: UIButton {
    // MARK: Lifecycle

    init(bgColor: UIColor = .white.withAlphaComponent(0.1)) {
        self.bgColor = bgColor
        super.init(frame: .zero)

        backgroundColor = .clear
        layer.insertSublayer(backgroundLayer, below: imageView?.layer)

        layoutSubviews()
    }

    private let bgColor: UIColor

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = bounds.height * 0.5
        backgroundLayer.backgroundColor = bgColor.cgColor

        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
    }

    // MARK: Private

    private let backgroundLayer = CALayer()
}
