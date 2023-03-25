//
//  SearchAPIRequest.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/11.
//

import Foundation

/// 搜尋
struct SearchRequest: APIRequest {
    // MARK: Lifecycle

    init(term: String, limit: Int, offset: Int) {
        self.term = term
        self.limit = limit
        self.offset = offset
    }

    // MARK: Internal

    typealias Response = [[String]]

    let path: String = "/search"
    let method: HTTPMethod = .get
    var headers: [String: String]?

    /// 要搜索的 URL 編碼文本字符串 e.g. jack+johnson
    let term: String

    /// 單次搜尋筆數上限
    let limit: Int

    /// 偏移量，分頁機制相關
    ///  e.g. 全部12首歌 -> limit 設為 10，offset 設為 1 -> 回傳第 2~11 首
    let offset: Int

    // TODO: 加上國家與語言，讓搜尋結果更加精準
    var parameters: [String: Any]? {
        return ["term": term,
                "media": media,
                "limit": limit,
                "offset": offset,
                "country": country,
                "lang": language]
    }

    var body: Data? {
        return nil
    }

    // MARK: Private

    /// 媒體種類(強制設為音樂)
    private let media: String = "music"

    /// 國家代碼
    private var country: String {
        LocaleManager.countryCode
    }

    /// 語言代碼
    private var language: String {
        LocaleManager.languageId
    }
}
