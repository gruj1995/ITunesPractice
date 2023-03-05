//
//  ITunesService+Search.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

extension ITunesService {
    /// 搜尋
    struct SearchRequest: CustomRequest {
        // MARK: Lifecycle

        init(term: String, limit: Int, offset: Int) {
            self.term = term
            self.limit = limit
            self.offset = offset
        }

        // MARK: Public

        var adapters: [CustomRequestAdapter] {
            return [
                CustomPathAdapter(path: path),
                CustomHTTPMethodAdapter(method: method),
                CustomQueryParamsAdapter(queryParams: queryParams),
                CustomContentTypeAdapter(contentType: contentType)
            ]
        }

        // MARK: Internal

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

        var queryParams: [String: String]? {
            return ["term": term,
                    "media": media,
                    "limit": "\(limit)",
                    "offset": "\(offset)"]
        }

        // MARK: Private

        /// 要搜索的 URL 編碼文本字符串 e.g. jack+johnson
        private let term: String

        /// 媒體種類(強制設為音樂)
        private let media: String = "music"

        /// 單次搜尋筆數上限
        private let limit: Int

        /// 偏移量(搜尋結果分頁機制相關)
        private let offset: Int

        // TODO: 修改
        func fetchTracks(completion: @escaping ((Result<SearchResponse, Error>) -> Void)) {

            guard let request = try? self.buildRequest() else {
                completion(.failure(AlamofireAdapter.shared.getNilDataError()))
                return
            }

            ApiEngine.shared.requestDecodableWithResult(request) { (result: Result<SearchResponse, ApiEngineError>) in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

