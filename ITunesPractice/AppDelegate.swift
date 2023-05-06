//
//  AppDelegate.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/17.
//

import AVFoundation
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

        // 生成單例類
        MusicPlayer.shared.configure()
        MatchingHelper.shared.configure()

        // 指定音訊會話類型為 .playback，讓 App 在背景、螢幕鎖定、silent mode 都能繼續播放音樂
        try? AVAudioSession.sharedInstance().setCategory(.playback)

        // 監控網路變化
        NetworkMonitor.shared.startMonitoring()

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

    /// 設置螢幕支持的方向
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

extension AppDelegate {
    // TODO: 建立單獨的類管理,目前沒有使用
    private func setNavigationBarAppearance() {
        // 返回按鈕樣式
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        // iOS 15 捲動的內容跟 bar 沒有重疊時使用
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithDefaultBackground()
        scrollEdgeAppearance.backgroundColor = .black
        scrollEdgeAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        scrollEdgeAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        scrollEdgeAppearance.backButtonAppearance = backButtonAppearance

        // iOS 15 捲動的內容跟 bar 重疊時使用
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // 透明背景且無陰影(隱藏底部邊框)
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        appearance.backButtonAppearance = backButtonAppearance
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
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
