//
//  ActionButtonAlertController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/3.
//

import UIKit

// MARK: - ActionButtonAlertController

// https://stackoverflow.com/questions/43823331/uialertcontroller-action-sheet-without-blurry-view-effect/51311166#51311166

/// 為了將Action的背景色都設為統一的顏色而建立的子類
class ActionButtonAlertController: UIAlertController {
    var actionButtonBackgroundColor: UIColor = .systemGray5 {
        didSet {
            // Invalidate current colors on change.
            view.setNeedsLayout()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for subview in view.allSubviews {
            if let label = subview as? UILabel, label.textColor == .white {
                label.textColor = .secondaryLabel
            }
            if let color = subview.backgroundColor, color != .clear {
                subview.backgroundColor = actionButtonBackgroundColor
            }

            // 這邊使用了 UIKit 的私有 API，可能會被 App Store 審核拒絕
            if let visualEffectView = subview as? UIVisualEffectView,
                String(describing: subview).contains("Separator") == false {
                visualEffectView.effect = nil
                visualEffectView.contentView.backgroundColor = actionButtonBackgroundColor
            }
        }

        popoverPresentationController?.backgroundColor = actionButtonBackgroundColor
    }
}

private extension UIView {
    /// All child subviews in view hierarchy plus self.
    var allSubviews: [UIView] {
        var views = [self]
        subviews.forEach {
            views.append(contentsOf: $0.allSubviews)
        }

        return views
    }
}
