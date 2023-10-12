//
//  YTSearchResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation

struct YTSearchResponse: Codable {
    let nextPageToken: String?
    let items: [SearchItem]?

    enum CodingKeys: String, CodingKey {
        case nextPageToken
        case items
    }
}

struct SearchItem: Codable {
    let id: VideoID?
    let snippet: Snippet?

    enum CodingKeys: String, CodingKey {
        case id
        case snippet
    }

    struct VideoID: Codable {
        let videoId: String?

        enum CodingKeys: String, CodingKey {
            case videoId
        }
    }
}

struct Snippet: Codable {
    // 資源的建立日期和時間。這個值會以 ISO 8601 格式指定
    let publishedAt: String?
    let channelId: String?
    let title: String?
    let description: String?
    let thumbnails: Thumbnails?
    let channelTitle: String?
//    // 表示 video 或 channel 資源是否包含現場直播內容。有效屬性值為 upcoming、live 和 none。
//    let liveBroadcastContent: String?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title
        case description
        case thumbnails
        case channelTitle
//        case liveBroadcastContent
    }
}

struct Thumbnails: Codable {
    let standard: Thumbnail?
    let medium: Thumbnail?
    let high: Thumbnail?

    enum CodingKeys: String, CodingKey {
        case standard = "default"
        case medium
        case high
    }

    // 縮圖圖片
    struct Thumbnail: Codable {
        let url: String?

        enum CodingKeys: String, CodingKey {
            case url
        }
    }
}
