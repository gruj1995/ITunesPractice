//
//  PaddingLabel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import UIKit

public class PaddingLabel: UILabel {

    /// 外部設置四周間距
    public var textInsets = UIEdgeInsets.zero

    public var width: CGFloat { frame.width + textInsets.left + textInsets.right }

    public var height: CGFloat { frame.height + textInsets.top + textInsets.bottom }

    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        guard text != nil else {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }

        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
