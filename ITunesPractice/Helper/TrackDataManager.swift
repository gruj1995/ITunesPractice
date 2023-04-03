//
//  TrackDataManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/3.
//

import Foundation

class TrackDataManager {
    static let shared = TrackDataManager()

    func addToLibrary(_ track: Track) {
        var currentTracks = UserDefaults.standard.tracks
        currentTracks.appendIfNotContains(track)
        UserDefaults.standard.tracks = currentTracks
    }

    func removeFromLibrary(_ track: Track) {
        var currentTracks = UserDefaults.standard.tracks
        currentTracks.removeAll { $0 == track }
        UserDefaults.standard.tracks = currentTracks
    }
}
