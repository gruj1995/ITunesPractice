//
//  UIViewController+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/5.
//

import UIKit

extension UIViewController {
    /// 上升彈窗
    func presentBottomAlert(presenter: Presenter, presentedVC: UIViewController, height: CGFloat = Constants.screenHeight, animated: Bool = true) {
        let popupHeight = Constants.screenHeight * height / 812
        presenter.popupSize = CGSize(width: Constants.screenWidth, height: popupHeight)
        presenter.center = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight - popupHeight / 2)
        presenter.presentViewController(presentingVC: self, presentedVC: presentedVC, animated: animated, completion: nil)
    }

    /// 點擊任意處取消鍵盤輸入狀態
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }

    /// 加入讀取動畫
    func loadingAction() {
        DispatchQueue.main.async {
            let loading = LoadingView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)))
            loading.setup(to: self.view)
        }
    }

    /// 移除讀取動畫
    func finishLoading() {
        DispatchQueue.main.async {
            for view in self.view.subviews {
                if let loading = view as? LoadingView {
                    loading.removeView()
                }
            }
        }
    }
}
