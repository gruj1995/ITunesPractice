//
//  CustomPathAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// Path 的 轉接器
struct CustomPathAdapter: CustomRequestAdapter {
    let path: String

    func adapted(_ request: URLRequest) throws -> URLRequest {
        guard let domain = request.url?.absoluteString else {
            throw RequestError.urlError
        }
        guard var urlComponent = URLComponents(string: domain) else {
            throw RequestError.urlError
        }
        if urlComponent.path == "/" {
            urlComponent.path = path
        } else {
            urlComponent.path += path
        }

        guard let url = urlComponent.url else {
            throw RequestError.urlError
        }
        return URLRequest(url: url)
    }
}
