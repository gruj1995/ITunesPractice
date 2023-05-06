//
//  UIApplication+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import UIKit

extension UIApplication {
    var keyWindowCompact: UIWindow? {
        if #available(iOS 13.0, *) {
            guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
                for scene in UIApplication.shared.connectedScenes {
                    if let windowScene = scene as? UIWindowScene {
                        for window in windowScene.windows where window.isKeyWindow {
                            return window
                        }
                    }
                }
                return nil
            }
            return keyWindow
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    var rootViewController: UIViewController? {
        keyWindowCompact?.rootViewController
    }

    func getTopViewController(base: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
