//
//  Constants.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import UIKit

enum Constants {

    static let itunesDomain = "https://itunes.apple.com"

//    static let yoububeAPIUrl = "https://www.googleapis.com/youtube/v3"
    // 自製抓取 youtube 資料的 API 的網址
    static let youtubeDomain = "http://127.0.0.1:8000/"

    /// Youtube API 金鑰
    static let youtubeAPIKey = "AIzaSyC0a0eOX_Epd_ROSjzEoNZdn63vvI_zLSg"

    /// 一般請求Timeout
    static let timeoutIntervalForRequest = TimeInterval(30)

    /// long polling Timeout(Server設30秒 所以client設60秒 要聽到server的正常timeout訊息)
    static let timeoutIntervalForLongPolling = TimeInterval(60)

    static let screenSize: CGRect = UIScreen.main.bounds

    static let screenWidth = Constants.screenSize.width

    static let screenHeight = Constants.screenSize.height

    static let statusBarHeight = UIApplication.shared.statusBarFrame.height

    static let padding: CGFloat = 16.0
}
