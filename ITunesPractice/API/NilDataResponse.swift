//
//  NilDataResponse.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

/// Nil Data 回應物件 (當後端定義的正確回應物件(statusCode=2XX)為空時，可以使用此物件)
public struct NilDataResponse: Codable {

    /// 狀態碼
    public var statusCode: Int
    
    /// 初始化
    public init(statusCode: Int) {
        self.statusCode = statusCode
    }
}
