//
//  ITunesService+Lookup.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/27.
//

import Foundation

extension ITunesService {
    /// 搜尋
    struct LookupRequest: CustomRequest {
        // MARK: Lifecycle

        init(trackId: Int) {
            self.trackId = trackId
        }

        // MARK: Internal

        typealias Response = [[String]]

        var adapters: [CustomRequestAdapter] {
            return [
                CustomPathAdapter(path: path),
                CustomHTTPMethodAdapter(method: method),
                CustomQueryParamsAdapter(queryParams: queryParams),
                CustomContentTypeAdapter(contentType: contentType)
            ]
        }

        var path: String {
            "/lookup"
        }

        var method: AlamofireAdapter.HTTPMethod {
            return .get
        }

        var contentType: ContentType {
            return .json
        }

        var queryParams: [String: String]? {
            return ["id": "\(trackId)"]
        }

        // TODO: 修改
        func fetchTrack(completion: @escaping ((Result<Track?, Error>) -> Void)) {
            guard let request = try? buildRequest() else {
                completion(.failure(AlamofireAdapter.shared.getNilDataError()))
                return
            }

            ApiEngine.shared.requestDecodableWithResult(request) { (result: Result<SearchResponse, ApiEngineError>) in
                switch result {
                case .success(let response):
                    completion(.success(response.results.first))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        // MARK: Private

        /// 音樂ID
        private let trackId: Int
    }
}
