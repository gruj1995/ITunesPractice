//
//  NetworkManagerExtensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation
import PromiseKit
import Alamofire

extension NetworkManager {

    func getData<T: Codable>(method: HTTPMethod = .get, action: Action, ofType: T.Type, parameters: Parameters? = nil, completion: @escaping ((Swift.Result<T, Error>)) -> Void) {
        let url = action.url
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default

        session.request(url, method: method.toAlamofireHTTPMethod(), parameters: parameters, encoding: encoding, headers: self.headers) { $0.timeoutInterval = 30.0 }
            .validate(statusCode: 200 ..< 300)
            .responseString { (response) in
            switch response.result {
            case .success:
                guard let apiResponseData = response.data else {
                    completion(.failure(AppError.noData))
                    return
                }
                do {
                    let response = try self.decoder.decode(T.self, from: apiResponseData)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getData<T: Codable>(method: HTTPMethod = .get, action: Action, ofType: T.Type, parameters: Parameters? = nil) -> Promise<T> {
        return Promise<T> { seal in
            let url = action.url
            var encoding: ParameterEncoding
            if method == .post {
                encoding = JSONEncoding.default
            } else {
                encoding = URLEncoding.default
            }

            session.request(url, method: method.toAlamofireHTTPMethod(), parameters: parameters, encoding: encoding, headers: self.headers) { $0.timeoutInterval = 30.0 } .validate(statusCode: 200 ..< 300)
                .responseString { (response) in

                switch response.result {
                case .success(_):
                    if let apiResponseData = response.data {
                        do {
                            let response = try self.decoder.decode(T.self, from: apiResponseData)
                            seal.fulfill(response)
                        } catch {
                            seal.reject(error)
                        }
                    } else {
                        seal.reject(AppError.message("empty response"))
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func getStringData(method: HTTPMethod = .get, action: Action, parameters: Parameters? = nil) -> Promise<String> {
        return Promise<String> { seal in
            let url = action.url
            var encoding: ParameterEncoding
            if method == .post {
                encoding = JSONEncoding.default
            } else {
                encoding = URLEncoding.default
            }

            session.request(url, method: method.toAlamofireHTTPMethod(), parameters: parameters, encoding: encoding, headers: self.headers) { $0.timeoutInterval = 30.0 } .validate(statusCode: 200 ..< 300)
                .responseString { (response) in

                switch response.result {
                case .success(let string):
                    seal.fulfill(string)
//                    if let data = response.data,
//                       let result = String(data: data, encoding: .utf8) {
//                        seal.fulfill(result)
//                    } else {
//                        seal.reject(AppError.message("empty response"))
//                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}

extension NetworkManager {
    // 官方文件參數： https://developers.google.com/youtube/v3/docs/search/list?hl=zh-tw
//    func fetchYTSearchResponse(term: String, limit: Int = 20, nextPageToken: String? = nil, _ completion: @escaping ((Swift.Result<YTSearchResponse, Error>) -> Void)) {
//        var parameters: Parameters = [
//            "key": Constants.youtubeAPIKey, // 使用 API 只能取得公開的播放清單
//            "part": "id, snippet",// 必填，把需要的資訊列出來
//            "q": term,// 查詢文字
//            "maxResults": limit,// 預設為五筆資料，可以設定1~50
//            "type": "vedio"
//        ]
//        if let nextPageToken {
//            parameters["pageToken"] = nextPageToken
//        }
//        firstly {
//            getData(action: .ytSearchList, ofType: YTSearchResponse.self, parameters: parameters)
//        }.done { response in
//            completion(.success(response))
//        }.catch { error in
//            completion(.failure(error))
//        }
//    }

    func searchYTVideos(term: String, _ completion: @escaping ((Swift.Result<[VideoInfo], Error>) -> Void)) {
        let parameters: Parameters = ["keyword": term]
        firstly {
            getData(action: .ytSearchVideos, ofType: VideoSearchResponse.self, parameters: parameters)
        }.done { response in
            completion(.success(response.data ?? []))
        }.catch { error in
            completion(.failure(error))
        }
    }

    /// 取得關鍵字建議
    func fetchYTAutoSuggest(term: String, _ completion: @escaping ((Swift.Result<[String], Error>) -> Void)) {
        let parameters: Parameters = [
            "client": "youtube",
            "ds": "yt",
            "hl": "zh-Hant", // 語言
            "q": term // 查詢文字,
        ]
        firstly {
            getStringData(action: .ytAutoSuggest, parameters: parameters)
        }.done { response in
            let items = self.parseSuggestData(response)
            completion(.success(items))
        }.catch { error in
            completion(.failure(error))
        }
    }

    private func parseSuggestData(_ text: String) -> [String] {
        // 使用正则表达式提取 JSON 数据
        if let range = text.range(of: "\\[.*\\]", options: .regularExpression) {
            let jsonSubstring = text[range]

            // 转换 JSON 字符串为 Data
            if let jsonData = jsonSubstring.data(using: .utf8) {
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                if let data = jsonObject as? [Any], data.count >= 2,
                   let innerArray = data[1] as? [[Any]] {
                    let extractedArray = innerArray.compactMap { innerItem -> String? in
                        if innerItem.count >= 1, let stringItem = innerItem[0] as? String {
                            return stringItem
                        }
                        return nil
                    }
                    return extractedArray
                } else {
                    Logger.log("无法提取字符串数组")
                }
            }
        } else {
            Logger.log("Error parsing JSON")
        }
        return []
    }
}
