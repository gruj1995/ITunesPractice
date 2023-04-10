//
//  CustomRequestAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// 請求轉接器
public protocol CustomRequestAdapter {
    
    func adapted(_ request: URLRequest) throws -> URLRequest
}
