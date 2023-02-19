//
//  ITunesService+Search.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

extension ITunesService {
    
    /// 搜尋
    struct  SearchRequest: CustomRequest {
        
        typealias Response = [[String]]
        
        var path: String {
            "/search"
        }
        
        var method: AlamofireAdapter.HTTPMethod {
            return .get
        }
        
        var contentType: ContentType {
            return .json
        }
        
        var queryParams: [String: String]?{
            return ["term": term,
                    "media": media,
                    "limit": "\(limit)",
                    "offset": "\(offset)"]
        }
        
        public var adapters: [CustomRequestAdapter] {
            return [
                CustomPathAdapter(path: path),
                CustomHTTPMethodAdapter(method: method),
                CustomQueryParamsAdapter(queryParams: queryParams),
                CustomContentTypeAdapter(contentType: contentType)
            ]
        }
        
        init(term: String, limit: Int, offset: Int){
            self.term = term
            self.limit = limit
            self.offset = offset
        }

        /// 要搜索的 URL 編碼文本字符串 e.g. jack+johnson
        private let term: String
        
        /// 媒體種類(強制設為音樂)
        private let media: String = "music"
        
        /// 單次搜尋筆數上限
        private let limit: Int
        
        /// 偏移量(搜尋結果分頁機制相關)
        private let offset: Int
    }
}
