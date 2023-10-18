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
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        fetchRemoteConfig()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
