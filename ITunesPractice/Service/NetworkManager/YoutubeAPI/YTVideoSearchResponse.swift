//
//  YTVideoSearchResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import Foundation

struct YTVideoSearchResponse: Codable {
    let data: [VideoInfo]?
}

struct VideoInfo: Codable {
    let channelId: String
    let channelTitle: String?
    let channelThumbnail: Thumbnail?
    let videoId: String
    let title: String?
    let thumbnails: [Thumbnail]?
    // 發布時間 (e.g. "1小時前")
    let publishedTimeText: String?
    let lengthText: String?
    let length: String?
    // (e.g. "觀看次數：1,000萬次")
    let viewCountText: String?
    // 直播收看人數(e.g. "100 人正在觀看")
    let liveViewCountText: String?

    var viewCount: String? {
        viewCountText ?? liveViewCountText
    }

    // 是否正在直播
    var isLive: Bool {
        !liveViewCountText.isEmptyOrNil
    }

    private enum CodingKeys: String, CodingKey {
        case channelId
        case channelTitle
        case channelThumbnail
        case videoId
        case title
        case thumbnails
        case publishedTimeText
        case lengthText
        case length
        case viewCountText
        case liveViewCountText
    }
}

struct Thumbnail: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}
