//
//  UserDefaults+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/4.
//

import Foundation
import Combine

extension UserDefaults {
    private enum Keys {
        static let tracks = "tracks"
        static let playerDisplayMode = "playerDisplayMode"
    }

    // MARK: - Tracks In Library

    var tracks: [Track] {
        get {
            UserDefaultsHelper.shared.get(forKey: Keys.tracks, as: [Track].self)  ?? []
        }
        set {
            UserDefaultsHelper.shared.set(newValue, forKey: Keys.tracks)
            NotificationCenter.default.post(name: .toBePlayedTracksDidChanged, object: self)
        }
    }

    var playerDisplayMode: PlayerDisplayMode {
        get {
            UserDefaultsHelper.shared.get(forKey: Keys.playerDisplayMode, as: PlayerDisplayMode.self) ?? .trackInfo
        }
        set {
            UserDefaultsHelper.shared.set(newValue, forKey: Keys.playerDisplayMode)
            NotificationCenter.default.post(name: .playerDisplayModeDidChanged, object: self)
        }
    }
}
