//
//  CustomJsonBodyParamsAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// JsonBodyParams 的 轉接器
struct CustomJsonBodyParamsAdapter: CustomRequestAdapter {
    let bodyParams: [String: Any]

    func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
        return request
    }
}
