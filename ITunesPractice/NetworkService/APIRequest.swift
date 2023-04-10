//
//  APIRequest.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/11.
//

import Foundation

protocol APIRequest {
    // 讓每個API請求定義自己的特定回應類型
    associatedtype Response: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: ContentType { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
}

extension APIRequest {
    var baseURL: URL {
        return URL(string: Constants.itunesDomain)!
    }

    var contentType: ContentType {
        return .json
    }
}
