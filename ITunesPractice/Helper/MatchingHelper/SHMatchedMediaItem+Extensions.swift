//
//  SHMatchedMediaItem+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import ShazamKit
import MusicKit

// MARK: SHMatchedMediaItem

extension SHMatchedMediaItem {
    func convertToTrack() -> Track {
        // 要取得 songs 需要請求媒體庫的權限，要在 Info.plist 添加 Privacy - Media Library Usage Description
        guard let song = songs.first,
              let songID = Int(song.id.rawValue)
        else {
            return createDefaultTrack()
        }
        return convertToTrackWithSong(song, songID: songID)
    }

    private func createDefaultTrack() -> Track {
        let track = Track(
            artworkUrl100: artworkURL?.absoluteString ?? "",
            collectionName: "",
            artistName: artist ?? "",
            trackId: 0,
            trackName: title ?? "",
            releaseDate: "",
            artistViewUrl: "",
            collectionViewUrl: "",
            previewUrl: "",
            trackViewUrl: "")
        return track.autoIncrementID()
    }

    private func convertToTrackWithSong(_ song: Song, songID: Int) -> Track {
        var track = createDefaultTrack()
        track.trackId = songID
        track.collectionName = song.albumTitle ?? ""
        track.releaseDate = song.releaseDate?.ISO8601Format() ?? ""
        track.artistViewUrl = song.artistURL?.absoluteString ?? ""
        track.videoUrl = videoURL
        track.trackViewUrl = song.url?.absoluteString ?? ""
        track.previewUrl = song.previewAssets?.first?.url?.absoluteString ?? ""
        return track
    }
}
