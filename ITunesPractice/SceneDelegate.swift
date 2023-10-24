//
//  SceneDelegate.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/17.
//

import UIKit
import FirebaseRemoteConfig
import SwiftyJSON

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let remoteConfig = RemoteConfig.remoteConfig()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        fetchRemoteConfig()
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AVPlayerViewControllerManager.shared.reconnectPlayer()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AVPlayerViewControllerManager.shared.disconnectPlayer()
    }

    private func fetchRemoteConfig() {
        // 方便測試時快速看到 RemoteConfig 的變化
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetch { status, error in
            switch status {
            case .success:
                self.remoteConfig.activate { _, _ in
                    if let apiDomain = self.remoteConfig.configValue(forKey: "api_domain").stringValue,
                       !apiDomain.isEmpty {
                        UserDefaults.apiDomain = apiDomain
                    } else {
                        Logger.log("Youtube api domain error!")
                    }
                }
            default:
                Logger.log(("Firebase RemoteConfig Error: \(error?.localizedDescription ?? "No error available.")"))
            }
        }
    }
}
