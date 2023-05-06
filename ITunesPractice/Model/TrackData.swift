//
//  TrackData.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/6.
//

import Foundation

// MARK: - Track

struct TrackData: Codable, CustomStringConvertible {
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

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case artworkUrl100, collectionName, artistName, trackId, trackName, releaseDate, artistViewUrl, collectionViewUrl, previewUrl, trackViewUrl
    }
}

extension TrackData {
    func convertToTrack() -> Track {
        Track(artworkUrl100: artworkUrl100, collectionName: collectionName, artistName: artistName, trackId: trackId, trackName: trackName, releaseDate: releaseDate, artistViewUrl: artistViewUrl, collectionViewUrl: collectionViewUrl, previewUrl: previewUrl, trackViewUrl: trackViewUrl)
    }
}
