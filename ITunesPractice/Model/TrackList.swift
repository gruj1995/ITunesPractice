//
//  TrackList.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/25.
//

import Foundation

// MARK: - TrackList

struct TrackList: Codable {
    // MARK: Internal

    let results: [Track]

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case results
    }
}
