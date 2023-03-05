//
//  ToastHelper.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/5.
//

import UIKit

class ToastHelper {
    // MARK: Internal

    enum Position {
        case bottom
        case center
        case top
    }

    // MARK: - Init

    static let shared = ToastHelper()

    // MARK: - Instance Methods

    func showToast(text: String, position: Position, font: UIFont = .systemFont(ofSize: 15), backgroundColor: UIColor = .gray, textColor: UIColor = .white, cornerRadius: CGFloat = 10.0, alignment: NSTextAlignment = .center, withDuration duration: TimeInterval = 1.5, delay: TimeInterval = 1.5) {
        // 用來呈現 toast 的畫面
        guard let toastWindow = UIApplication.shared.keyWindowCompact else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideToast(window: toastWindow)

            let toastLb = self.createToastLabel(text: text, font: font, backgroundColor: backgroundColor, textColor: textColor, cornerRadius: cornerRadius, alignment: alignment)

            self.calculateLabelPosition(toastLb: toastLb, position: position)
            toastWindow.addSubview(toastLb)

            // 建立一個 UIViewPropertyAnimator 物件，並設定相關屬性
            let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
                toastLb.alpha = 0.0
            }

            // 設定動畫完成後的動作
            animator.addCompletion { _ in
                toastLb.removeFromSuperview()
            }

            // 執行動畫
            animator.startAnimation(afterDelay: delay)
        }
    }

    // MARK: Private

    private func hideToast(window: UIWindow) {
        window.subviews
            .compactMap { $0 as? UILabel }
            .filter { $0.tag == 9999 }
            .forEach { $0.removeFromSuperview() }
    }

    private func createToastLabel(text: String, font: UIFont, backgroundColor: UIColor, textColor: UIColor, cornerRadius: CGFloat, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = backgroundColor
        label.textColor = textColor
        label.layer.cornerRadius = cornerRadius
        label.textAlignment = alignment
        label.font = font
        label.layer.masksToBounds = true
        label.tag = 9999 // tag：hideToast 時用來判斷要remove哪個label
        label.text = text
        return label
    }

    private func calculateLabelPosition(toastLb: UILabel, position: Position) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let maxSize = CGSize(width: screenWidth - 40, height: screenHeight)
        let padding: CGFloat = 20

        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height

        if maxSize.width >= expectedSize.width {
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height {
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)

        var minY: CGFloat!
        switch position {
        case .bottom:
            minY = screenHeight - expectedSize.height - 60 - padding
        case .center:
            minY = (screenHeight - expectedSize.height - padding) / 2
        case .top:
            minY = expectedSize.height + 60 + padding
        }

        toastLb.frame = CGRect(x: (screenWidth / 2) - ((expectedSize.width + padding) / 2), y: minY, width: expectedSize.width + padding, height: expectedSize.height + padding)
    }
}
