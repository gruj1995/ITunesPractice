//
//  VideoSearchResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import Foundation

struct VideoSearchResponse: Codable {
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

private extension String {
    func formatViewCount() -> String {
        let viewCount = replacingOccurrences(of: "觀看次數：", with: "").replacingOccurrences(of: "次", with: "").replacingOccurrences(of: ",", with: "")
        return "\(getDealNum(with: viewCount))次"
    }

    func getDealNum(with string: String) -> String {
        let numberA = NSDecimalNumber(string: string)
        var numberB: NSDecimalNumber?
        var unitStr: String = ""

        switch string.count {
        case 5..<7:
            numberB = NSDecimalNumber(string: "10000")
            unitStr = "萬"
        case 7:
            numberB = NSDecimalNumber(string: "1000000")
            unitStr = "百萬"
        case 8:
            numberB = NSDecimalNumber(string: "10000000")
            unitStr = "千萬"
        case 9...:
            numberB = NSDecimalNumber(string: "100000000")
            unitStr = "億"
        default:
            return string
        }

        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )

        let numResult = numberA.dividing(by: numberB ?? NSDecimalNumber.one, withBehavior: roundingBehavior)
        return numResult.stringValue + unitStr
    }
}
