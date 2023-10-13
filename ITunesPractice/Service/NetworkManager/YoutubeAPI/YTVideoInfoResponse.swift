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
    let channelId: String?
    let channelTitle: String?
    let channelThumbnails: [Thumbnail]?
    let videoId: String?
    let title: String?
    // (e.g.首播日期：2021年5月20日)
    let publishedTimeText: String?
    // 觀看次數 (e.g. "觀看次數：1,000次")
    let viewCountText: String?
    // 說明欄內容
    let description: String?

    var shortViewConuntText: String? {
        viewCountText?.formatViewCount()
    }

    private enum CodingKeys: String, CodingKey {
        case channelId
        case channelTitle
        case channelThumbnails
        case videoId
        case title
        case publishedTimeText
        case viewCountText
        case description
    }
}
