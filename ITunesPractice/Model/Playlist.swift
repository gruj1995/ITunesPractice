//
//  Playlist.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Foundation

// MARK: - Playlist

struct Playlist: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl
        case tracks
    }

    var id: Int
    var name: String
    var description: String
    var imageUrl: URL?
    var tracks: [Track]

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    /// 自動增加 id
    func autoIncrementID() -> Playlist {
        UserDefaults.autoIncrementPlaylistID += 1
        var newItem = self
        newItem.id = UserDefaults.autoIncrementPlaylistID
        return newItem
    }
}

extension Playlist {
    init() {
        self.init(id: 0, name: "", description: "", tracks: [])
    }
}
