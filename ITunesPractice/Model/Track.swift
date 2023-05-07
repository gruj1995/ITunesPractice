//
//  Album.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

// MARK: - Track

struct Track: Codable, Equatable, Comparable, CustomStringConvertible {
    // MARK: Lifecycle

    init(id: Int = 0, artworkUrl100: String, collectionName: String, artistName: String, trackId: Int, trackName: String, releaseDate: String, artistViewUrl: String, collectionViewUrl: String, previewUrl: String, trackViewUrl: String, videoUrl: URL? = nil, searchDate: Date? = nil) {
        self.id = id
        self.artworkUrl100 = artworkUrl100
        self.collectionName = collectionName
        self.artistName = artistName
        self.trackId = trackId
        self.trackName = trackName
        self.releaseDate = releaseDate
        self.artistViewUrl = artistViewUrl
        self.collectionViewUrl = collectionViewUrl
        self.previewUrl = previewUrl
        self.trackViewUrl = trackViewUrl
        self.videoUrl = videoUrl
        self.searchDate = searchDate ?? Date()
    }

    // MARK: Internal

    // MARK: 為了 Shazam 新增的參數

    let id: Int

    /// 影片網址(搜尋結果)
    var videoUrl: URL?

    /// 搜尋日期
    var searchDate: Date

    // MARK: Track 的參數

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
            "trackViewUrl: \(trackViewUrl)\n" +
            "videoUrl: \(String(describing: videoUrl))\n"
    }

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

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.trackId == rhs.trackId
    }

    static func < (lhs: Track, rhs: Track) -> Bool {
        return lhs.searchDate < rhs.searchDate
    }

    /// 回傳自動增加 id 後的 Track
    func autoIncrementID() -> Track {
        UserDefaults.autoIncrementTrackID += 1
        return Track(id: UserDefaults.autoIncrementTrackID, artworkUrl100: artworkUrl100, collectionName: collectionName, artistName: artistName, trackId: trackId, trackName: trackName, releaseDate: releaseDate, artistViewUrl: artistViewUrl, collectionViewUrl: collectionViewUrl, previewUrl: previewUrl, trackViewUrl: trackViewUrl)
    }

    /// 調整 iTunes API 回傳的圖片尺寸（100x100可能看起來模糊）
    func getArtworkImageWithSize(size: ITunesImageSize) -> URL? {
        URL(string: artworkUrl100.replace(target: "100x100", withString: "\(size.rawValue)x\(size.rawValue)"))
    }
}

extension Track {
    var isInLibrary: Bool {
        UserDefaults.libraryTracks.contains(self)
    }

    init(trackName: String, trackViewUrl: String) {
        UserDefaults.autoIncrementTrackID += 1
        self.init(id: UserDefaults.autoIncrementTrackID, artworkUrl100: "", collectionName: "", artistName: "", trackId: 0, trackName: trackName, releaseDate: "", artistViewUrl: "", collectionViewUrl: "", previewUrl: "", trackViewUrl: trackViewUrl)
    }
}
