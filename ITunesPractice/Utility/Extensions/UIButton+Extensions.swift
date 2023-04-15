//
//  UIButton+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/7.
//

import UIKit

private var buttonTouchEdgeInsets: UIEdgeInsets?

extension UIButton {
    /// 擴張按鈕點擊範圍
    /// 使用方式如下:
    /// button.touchEdgeInsets = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    var touchEdgeInsets: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &buttonTouchEdgeInsets) as? UIEdgeInsets
        }

        set {
            objc_setAssociatedObject(self,
                                     &buttonTouchEdgeInsets, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 擴張按鈕點擊範圍
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var frame = self.bounds

        if let touchEdgeInsets = self.touchEdgeInsets {
            frame = frame.inset(by: touchEdgeInsets)
        }

        return frame.contains(point)
    }

    func setRoundCornerButtonAppearance(isSelected: Bool, tintColor: UIColor?, image: UIImage? = nil) {
        if let image = image {
            setImage(image, for: .normal)
        }
        self.tintColor = isSelected ? tintColor : .white
        backgroundColor = isSelected ? .white : .clear
    }

    /// 生成固定圓角值的按鈕
    static func createRoundCornerButton(image: UIImage?, target: Any?, action: Selector) -> UIButton {
        let button = UIButton()
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        return button
    }
}
