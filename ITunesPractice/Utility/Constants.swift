//
//  Constants.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import UIKit

enum Constants {

    static let itunesDomain = "https://itunes.apple.com"

    /// 一般請求Timeout
    static let timeoutIntervalForRequest = TimeInterval(30)

    /// long polling Timeout(Server設30秒 所以client設60秒 要聽到server的正常timeout訊息)
    static let timeoutIntervalForLongPolling = TimeInterval(60)

    static let screenSize: CGRect = UIScreen.main.bounds

    static let screenWidth = Constants.screenSize.width

    static let screenHeight = Constants.screenSize.height
}
