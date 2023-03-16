//
//  PanDismissViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/17.
//

import UIKit

/// 實驗效果： 可以拖曳下拉，且位置低於畫面一半會 dismiss
class PanDismissViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }

    @objc
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began, .changed:
            view.frame.origin.y = max(translation.y, 0)
        case .ended:
            // 位置低於畫面一半，關閉視窗
            if translation.y > view.frame.size.height / 2 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
        }
    }

    // MARK: Private

    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        view.isUserInteractionEnabled = true
    }
}
