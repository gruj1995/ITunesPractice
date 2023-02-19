//
//  CustomContentTypeAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// ContentType 的 轉接器
struct CustomContentTypeAdapter: CustomRequestAdapter {
    let contentType: ContentType
    func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        return request
    }
}
