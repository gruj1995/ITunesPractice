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
        var currentTracks = UserDefaults.toBePlayedTracks
        currentTracks.appendIfNotContains(track)
        UserDefaults.toBePlayedTracks = currentTracks
    }

    func removeFromLibrary(_ track: Track) {
        var currentTracks = UserDefaults.toBePlayedTracks
        currentTracks.removeAll { $0 == track }
        UserDefaults.toBePlayedTracks = currentTracks
    }
}
