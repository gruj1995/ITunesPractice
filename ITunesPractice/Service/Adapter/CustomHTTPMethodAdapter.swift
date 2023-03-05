//
//  CustomHTTPMethodAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// HTTPMethod 的 轉接器
struct CustomHTTPMethodAdapter: CustomRequestAdapter {
    let method: AlamofireAdapter.HTTPMethod

    func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpMethod = method.rawValue
        return request
    }
}
