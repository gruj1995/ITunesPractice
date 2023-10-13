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
    let channelId: String?
    let channelTitle: String?
    let channelThumbnail: Thumbnail?
    let videoId: String?
    let title: String?
    let thumbnails: [Thumbnail]?
    let publishedTimeText: String?
    let lengthText: String?
    let length: String?
    let viewCountText: String?

    var shortViewConuntText: String? {
        viewCountText?.formatViewCount()
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
    }
}

struct Thumbnail: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}
