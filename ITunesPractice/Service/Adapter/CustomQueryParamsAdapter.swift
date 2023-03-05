//
//  CustomQueryParamsAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// QueryParams 的 轉接器
struct CustomQueryParamsAdapter: CustomRequestAdapter {
    let queryParams: [String: String]?

    func adapted(_ request: URLRequest) throws -> URLRequest {
        guard let domain = request.url?.absoluteString else {
            throw RequestError.urlError
        }
        guard var urlComponent = URLComponents(string: domain) else {
            throw RequestError.urlError
        }

        if let queryParams = queryParams {
            let queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlComponent.queryItems = queryItems
        } else {
            urlComponent.queryItems = nil
        }

        guard let url = urlComponent.url else {
            throw RequestError.urlError
        }
        return try URLRequest(url: url, method: request.method ?? .get, headers: request.headers)
    }
}
