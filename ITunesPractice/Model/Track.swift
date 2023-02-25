//
//  Album.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

// MARK: - Track

struct Track: Codable, CustomStringConvertible {
    // MARK: Internal

    /// 專輯封面圖示
    var artworkUrl: String

    /// 專輯名稱
    var collectionName: String

    /// 歌手
    var artistName: String

    /// 歌曲名稱
    var trackName: String

    /// 在iTunes上發行的日期(格式 ISO 8601: 2016-07-21T07:00:00Z)
    var releaseDate: String

    /// 發行日期(外部操作使用)
    var releaseDateString: String {
        let iso8601DateFormatter = DateUtility.iso8601DateFormatter
        return iso8601DateFormatter
            .date(from: releaseDate)?
            .toString(dateFormat: "yyyy/MM/dd") ?? ""
    }

    var description: String {
        return "artworkUrl: \(artworkUrl)\n" +
            "collectionName: \(collectionName)\n" +
            "artistName: \(artistName)\n" +
            "trackName: \(trackName)\n" +
            "releaseDate: \(releaseDate)\n"
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case artworkUrl = "artworkUrl100"
        case collectionName, artistName, trackName, releaseDate
    }
}
