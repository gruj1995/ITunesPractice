//
//  AppInfo.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import UIKit

enum AppInfo {
    static let appleID = "6448342626"
    static let bundleID = Bundle.main.bundleIdentifier ?? "Unknown"
    static let googleAPIKey = "AIzaSyDSM75kZ83CCGWdBqkUHOXAqYg2BhhBMoI"

    // 當前 App 版號
    static let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    // 當前 iOS 系統版本
    static let iOSVersion = UIDevice.current.systemVersion

    // App 名稱
    static var appName: String {
        // 先嘗試取得本地化顯示名稱
        if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        } else if let appName = Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String {
            // 再嘗試取得非本地化顯示名稱
            return appName
        } else {
            return "SquareMusic"
        }
    }
}
