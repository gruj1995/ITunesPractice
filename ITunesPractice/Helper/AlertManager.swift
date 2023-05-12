//
//  AlertManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/10.
//

import UIKit

/// 系統彈窗
class AlertManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = AlertManager()

    /// 顯示文字視窗
    /// - Parameters:
    ///    - title: 視窗標題
    ///    - message: 視窗訊息
    ///    - confirmTitle: 確認按鈕文字 預設為 Ok
    ///    - handler: 按下確認後執行的動作 預設無
    func showSingleMsgAlert(title: String?, message: String?, confirmTitle: String? = "Ok", handler: ((UIAlertAction) -> Void)? = nil) {
        let alertManager = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: confirmTitle, style: .default, handler: handler)
        alertManager.addAction(yesButton)
        if let visibleViewController = UIApplication.shared.getTopViewController() {
            visibleViewController.present(alertManager, animated: true, completion: nil)
        }
    }

    func showMsgAlert(title: String?, message: String?, confirmTitle: String, cancelTitle: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertManager = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: confirmTitle, style: .default, handler: handler)
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)

        alertManager.addAction(cancelButton)
        alertManager.addAction(confirmButton)

        if let visibleViewController = UIApplication.shared.getTopViewController() {
            visibleViewController.present(alertManager, animated: true, completion: nil)
        }
    }

    /// 顯示前往手機設定的視窗
    /// - Parameters:
    ///   - title: 視窗標題
    ///   - message: 視窗訊息
    ///   - settingURL: 要前往的設定
    func showSettingAlert(title: String?, message: String?, settingURL: String, cancellable: Bool = true) {
        if cancellable {
            showMsgAlert(title: title, message: message, confirmTitle: "前往設定".localizedString(), cancelTitle: "取消".localizedString()) { _ in
                if let url = URL(string: settingURL) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            showSingleMsgAlert(title: title, message: message, confirmTitle: "前往設定".localizedString()) { _ in
                if let url = URL(string: settingURL) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
