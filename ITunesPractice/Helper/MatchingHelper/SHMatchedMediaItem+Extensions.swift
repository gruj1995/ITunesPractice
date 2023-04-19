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
        //        Logger.log(message: "__+++ item \(self.debugDescription)")
        //        Logger.log(message: "__+++ song \(song.debugDescription)")
    }

    private func createDefaultTrack() -> Track {
        return Track(
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
    }

    private func convertToTrackWithSong(_ song: Song, songID: Int) -> Track {
        var track = createDefaultTrack()
        let urlString = getTrackViewUrlString(url: appleMusicURL, id: songID) ?? ""
        track.trackId = songID
        track.collectionName = song.albumTitle ?? ""
        track.releaseDate = song.releaseDate?.ISO8601Format() ?? ""
        track.artistViewUrl = song.artistURL?.absoluteString ?? ""
        track.collectionViewUrl = urlString
        track.trackViewUrl = urlString
        return track
    }

    private func getTrackViewUrlString(url: URL?, id: Int) -> String? {
        guard let url  else { return nil }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        if let newUrl = components?.url {
            // TODO: 這邊要調整寫法
            return newUrl.absoluteString + "?i=\(id)"
        }
        return nil
    }
}
