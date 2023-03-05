//
//  AppDelegate.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/17.
//

import UIKit
#if DEBUG
import FLEX
#endif

// MARK: - AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
#if DEBUG
        FLEXManager.shared.isNetworkDebuggingEnabled = true
#endif
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 要先到 info.plist 新增 key(View controller-based status bar appearance) 以下設置才有效
        UIApplication.shared.statusBarStyle = .lightContent

        // 設置所有 UIBarButtonItem 的 tinitColor
        UIBarButtonItem.appearance().tintColor = .appColor(.red1)
        
        setNavigationBarAppearance()

        // 修正ios 15 tableView section 上方多出的空白
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
        
#if DEBUG
        FLEXManager.shared.isNetworkDebuggingEnabled = true
#endif
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    // TODO: 移到主題色管理
    private func setNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        //        appearance.configureWithOpaqueBackground() // 預設背景及陰影
        //        appearance.configureWithTransparentBackground() // 透明背景且無陰影(隱藏底部邊框)
        // 模糊效果樣式(可調亮/暗程度)
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        // 返回按鈕樣式
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension UIWindow {
    #if DEBUG
    /// 搖動出現debug套件
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            FLEXManager.shared.showExplorer()
        }
    }
    #endif
}
