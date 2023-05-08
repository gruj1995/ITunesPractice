//
//  Playlist.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Foundation

struct Playlist: Codable, Equatable {
    var name: String
    var description: String
    var imageUrl: URL?
    var tracks: [Track]

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case imageUrl
        case tracks
    }
}
