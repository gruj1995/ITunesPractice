//
//  UIViewController+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/5.
//

import UIKit

extension UIViewController {
    func showToast(text: String, position: ToastHelper.Position = .bottom) {
        ToastHelper.shared.showToast(text: text, position: position)
    }
}
