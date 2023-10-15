//
//  YTVideoInfoResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Foundation

struct YTVideoInfoResponse: Codable {
    let data: YTVideoInfoData?

    struct YTVideoInfoData: Codable {
        let videoDetailInfo: VideoDetailInfo?
        let recommendedVideos: [VideoInfo]?
    }
}

struct VideoDetailInfo: Codable {
    let channelId: String
    let channelTitle: String?
    let channelThumbnails: [Thumbnail]?
    let videoId: String
    let title: String?
    // (e.g.首播日期：2021年5月20日)
    let publishedTimeText: String?
    // (e.g. "觀看次數：1,000萬次")
    let viewCountText: String?
    // 直播收看人數(e.g. "100 人正在觀看")
    let liveViewCountText: String?
    // 直播開始日期(e.g. "開始直播日期：2023年9月7日")
    let liveStartTimeText: String?
    // 說明欄內容
    let description: String?

    var viewCount: String? {
        viewCountText ?? liveViewCountText
    }

    private enum CodingKeys: String, CodingKey {
        case channelId
        case channelTitle
        case channelThumbnails
        case videoId
        case title
        case publishedTimeText
        case viewCountText
        case liveViewCountText
        case liveStartTimeText
        case description
    }
}
