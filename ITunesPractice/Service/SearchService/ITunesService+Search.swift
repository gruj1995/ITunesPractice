//
//  ITunesService+Search.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation
import Combine

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

        var method: HTTPMethod {
            return .get
        }

        var contentType: ContentType {
            return .json
        }

        var queryParams: [String: String]? {
            return ["term": term,
                    "media": media,
                    "limit": "\(limit)",
                    "offset": "\(offset)",
                    "country": country,
                    "lang": language]
        }

        // MARK: Private

        /// 要搜索的 URL 編碼文本字符串
        /// (目前測試 itunes api 有處理中文和空格轉加號，所以這邊不用特別加處理機制)
        private let term: String

        /// 媒體種類(強制設為音樂)
        private let media: String = "music"

        /// 單次搜尋筆數上限
        private let limit: Int

        /// 偏移量(搜尋結果分頁機制相關)
        private let offset: Int

        /// 國家代碼
        private var country: String {
            LocaleManager.countryCode
        }

        /// 語言代碼
        private var language: String {
            LocaleManager.languageId
        }

        // TODO: 會卡頓
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

        func fetchTracksByURLSession(completion: @escaping ((Result<SearchResponse, Error>) -> Void)) {
            guard let request = try? self.buildRequest() else {
                completion(.failure(AlamofireAdapter.shared.getNilDataError()))
                return
            }

            let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }

            session.resume()
        }

        func fetchTracksURLSessionPublisher() -> AnyPublisher<[Track], Error> {
            guard let request = try? self.buildRequest(),
                  let url = request.url else {
                return Fail(error: RequestError.urlError)
                    .eraseToAnyPublisher()
            }

            return URLSession.shared.dataTaskPublisher(for: url)
                       .map { $0.data }
                       .decode(type: SearchResponse.self, decoder: JSONDecoder())
                       .map { $0.results }
                       .mapError { error -> Error in
                           switch error {
                           case is URLError:
                               return ResponseError.nilData
                           default:
                               return ResponseError.nonHTTPResponse
                           }
                       }
                       .eraseToAnyPublisher()
        }
    }
}

