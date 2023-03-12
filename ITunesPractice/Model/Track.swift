//
//  Album.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

// MARK: - Track

struct Track: Codable, Equatable, CustomStringConvertible {
    // MARK: Internal

    /// 專輯封面圖示 (取得尺寸為100x100的圖片)
    var artworkUrl100: String

    /// 專輯名稱
    var collectionName: String

    /// 歌手
    var artistName: String

    /// 歌曲id
    var trackId: Int

    /// 歌曲名稱
    var trackName: String

    /// 在iTunes上發行的日期(格式 ISO 8601: 2016-07-21T07:00:00Z)
    var releaseDate: String

    /// 歌手預覽網址
    var artistViewUrl: String

    /// 專輯預覽網址
    var collectionViewUrl: String

    /// 單曲預覽網址
    var previewUrl: String

    /// 單曲網址
    var trackViewUrl: String

    /// 發行日期(外部操作使用)
    var releaseDateString: String {
        let iso8601DateFormatter = DateUtility.iso8601DateFormatter
        return iso8601DateFormatter
            .date(from: releaseDate)?
            .toString(dateFormat: "yyyy/MM/dd") ?? ""
    }

    /// 發行日期(外部操作使用)
    var releaseDateValue: Date? {
        let iso8601DateFormatter = DateUtility.iso8601DateFormatter
        return iso8601DateFormatter.date(from: releaseDate)
    }

    var description: String {
        return "artworkUrl: \(artworkUrl100)\n" +
            "collectionName: \(collectionName)\n" +
            "artistName: \(artistName)\n" +
            "trackId: \(trackId)\n" +
            "trackName: \(trackName)\n" +
            "releaseDate: \(releaseDate)\n" +
            "artistViewUrl: \(artistViewUrl)\n" +
            "collectionViewUrl: \(collectionViewUrl)\n" +
            "previewUrl: \(previewUrl)\n" +
            "trackViewUrl: \(trackViewUrl)\n"
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.trackId == rhs.trackId
    }

    /// 調整 iTunes API 回傳的圖片尺寸（100x100可能看起來模糊）
    func getArtworkImageWithSize(size: ITunesImageSize) -> URL? {
        URL(string: artworkUrl100.replace(target: "100x100", withString: "\(size.rawValue)x\(size.rawValue)"))
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case artworkUrl100, collectionName, artistName, trackId, trackName, releaseDate, artistViewUrl, collectionViewUrl, previewUrl, trackViewUrl
    }
}
