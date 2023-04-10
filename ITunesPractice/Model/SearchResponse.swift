//
//  SearchResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/25.
//

import Foundation

// MARK: - SearchResponse

struct SearchResponse: Codable {
    // MARK: Internal

    let results: [Track]

    let resultCount: Int

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case results, resultCount
    }
}
