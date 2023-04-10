//
//  ApiEngineError.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation
import Alamofire

public struct ApiEngineError: Error {

    /// 回應物件御三家(都儲存丟出去，有可能要客製化判斷)
    public var data: Data?
    public var error: Error?
    public var response: URLResponse?

    /// 初始化
    public init(data: Data?, error: Error?, response: URLResponse?) {
        self.data = data
        self.error = error
        self.response = response
    }
    
    /// 狀態碼
    public var statusCode: Int? {
        return (response as? HTTPURLResponse)?.statusCode
    }
    
    /// AFError
    public var afError: AFError? {
        return error as? AFError
    }
}
