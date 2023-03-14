//
//  PresentationController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2022/4/14.
//

import UIKit

class PresentationController: UIPresentationController {
    // MARK: Lifecycle

    init(presentedVC: UIViewController,
         presentingVC: UIViewController?,
         popupSize: CGSize,
         center: CGPoint,
         tapBgDidDismiss: Bool = true,
         bgColor: UIColor) {
        self.popupSize = popupSize
        self.center = center
        self.bgColor = bgColor
        self.tapBgDidDismiss = tapBgDidDismiss
        super.init(presentedViewController: presentedVC, presenting: presentingVC)
    }

    // MARK: Internal

    var onMaskViewTapped: (() -> Void)?

    /// 決定了彈框的frame
    override var frameOfPresentedViewInContainerView: CGRect {
        let x = center.x - popupSize.width / 2
        let y = center.y - popupSize.height / 2
        return CGRect(x: x, y: y, width: popupSize.width, height: popupSize.height)
    }

    /// 彈框即將顯示時執行所需要的操作
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(maskView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        maskView.addGestureRecognizer(tap)
        maskView.alpha = 0

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.maskView.alpha = 1
        }
    }

    /// 彈框顯示完畢時執行所需要的操作
    override func presentationTransitionDidEnd(_ completed: Bool) {}

    /// 彈框即將消失時執行所需要的操作
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.maskView.alpha = 0
        }
    }

    /// 彈框消失之後執行所需要的操作
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            maskView.removeFromSuperview()
        }
    }

    // MARK: Private

    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = bgColor
        if let frame = containerView?.frame {
            view.frame = frame
        }
        return view
    }()

    private let popupSize: CGSize

    private let center: CGPoint

    private let tapBgDidDismiss: Bool

    private let bgColor: UIColor

    @objc
    private func didTapBackground() {
        if tapBgDidDismiss {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
        onMaskViewTapped?()
    }
}
