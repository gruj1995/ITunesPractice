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
}
