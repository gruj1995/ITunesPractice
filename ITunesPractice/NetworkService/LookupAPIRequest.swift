//
//  LookupAPIRequest.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/11.
//

import Foundation

/// 查找指定條件
struct LookupAPIRequest: APIRequest {
    // MARK: Lifecycle

    init(trackId: Int) {
        self.trackId = trackId
    }

    // MARK: Internal

    typealias Response = [[String]]

    let path: String = "/lookup"
    let method: HTTPMethod = .get
    var headers: [String: String]?

    /// 音樂ID
    let trackId: Int

    var parameters: [String: Any]? {
        return ["id": "\(trackId)"]
    }

    var body: Data? {
        return nil
    }
}
