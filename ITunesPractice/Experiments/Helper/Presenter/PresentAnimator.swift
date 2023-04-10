//
//  PresentAnimator.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2022/4/14.
//

import UIKit

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.3

    var originFrame: CGRect = .zero

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        let isPresenting = (toVC?.presentingViewController == fromVC)

        guard let animatingView = isPresenting ? toView : fromView,
              let animatingVC = isPresenting ? toVC : fromVC else { return }

        let initialFrame = transitionContext.initialFrame(for: animatingVC)
        let finalFrame = transitionContext.finalFrame(for: animatingVC)
        if isPresenting,
           let toView = toView {
            containerView.addSubview(toView)
        }

        var animatingFrame = finalFrame
        animatingFrame.origin.y = containerView.frame.height + initialFrame.height
        animatingFrame = isPresenting ? animatingFrame : finalFrame
        animatingView.frame = animatingFrame
        UIView.animate(withDuration: duration) {
            var animatingFrame = finalFrame
            animatingFrame.origin.y = containerView.frame.height + initialFrame.height
            animatingFrame = isPresenting ? finalFrame : animatingFrame
            animatingView.frame = animatingFrame
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
}
