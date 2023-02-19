//
//  Constants.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// 常數
open class Constants {
    /// 預設的Domain
    public static let domain = "https://itunes.apple.com"

    /// 一般請求Timeout
    public static let timeoutIntervalForRequest = TimeInterval(30)

    /// long polling Timeout(Server設30秒 所以client設60秒 要聽到server的正常timeout訊息)
    public static let timeoutIntervalForLongPolling = TimeInterval(60)
}
