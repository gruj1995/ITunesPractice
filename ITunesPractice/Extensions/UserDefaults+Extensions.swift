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
    }

    // MARK: - Tracks In Library

    var tracks: [Track] {
        get {
            return UserDefaultsHelper.shared.get(forKey: Keys.tracks, as: [Track].self)  ?? []
        }
        set {
            UserDefaultsHelper.shared.set(newValue, forKey: Keys.tracks)
        }
    }
}
