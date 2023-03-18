//
//  Presenter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2022/4/14.
//

import UIKit

// MARK: - Presenter

class Presenter: NSObject {
    // MARK: Internal

    var popupSize: CGSize = .zero

    var center: CGPoint = .init(x: Constants.screenWidth / 2, y: Constants.screenHeight / 2)

    var tapBgDidDismiss: Bool = true

    var tapBtnBottomDidDismiss: Bool = true

    var bgColor: UIColor = .init(white: 1, alpha: 0.2)

    var onMaskViewTapped: (() -> Void)?

    func presentViewController(presentingVC: UIViewController, presentedVC: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentedVC.transitioningDelegate = self
        presentedVC.modalPresentationStyle = .custom
        presentingVC.present(presentedVC, animated: animated, completion: completion)
    }

    // MARK: Private

    private var presentAnimator = PresentAnimator()
}

// MARK: UIViewControllerTransitioningDelegate

extension Presenter: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PresentationController(presentedVC: presented,
                                                presentingVC: presenting,
                                                popupSize: popupSize,
                                                center: center,
                                                tapBgDidDismiss: tapBgDidDismiss,
                                                bgColor: bgColor)

        controller.onMaskViewTapped = { [weak self] in
            self?.onMaskViewTapped?()
        }

        return controller
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimator.originFrame = presenting.view.frame
        return presentAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
}
