//
//  RequestError.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

// MARK: - ApiRequestError

/// 回傳給外部的error物件，為了統一錯誤處理流程
open class ApiRequestError: Error {
    // MARK: Lifecycle

    /// 初始化
    ///
    /// - Parameters:
    ///   - code: 錯誤碼
    ///   - message: 錯誤訊息
    ///   - type: 錯誤類型
    public init(code: Int, message: String, type: ErrorType) {
        self.code = code
        self.message = message
        self.type = type
    }

    /// 初始化
    ///
    /// - Parameter error: 原生的錯誤物件
    public convenience init(error: NSError, type: ErrorType) {
        self.init(code: error.code, message: error.localizedDescription, type: type)
        originalError = error
    }

    // MARK: Open

    /// 原本的錯誤物件
    open var originalError: NSError?

    /// 類型
    open var type: ErrorType = .unknown

    /// 錯誤碼
    open var code: Int = 0

    /// 錯誤訊息
    open var message: String = ""

    /// 預設描述
    open var defaultDescription: String {
        return "錯誤碼：\(code)\n錯誤訊息：\(message)"
    }

    // MARK: Public

    /// 錯誤類型
    ///
    /// - unknown: 未知錯誤
    /// - mobileSystem: 系統錯誤，例：連線中斷
    /// - decoding: 解析錯誤，例：解json失敗
    /// - server: API回傳的錯誤，例：授權認證失敗
    /// - encoding: Request物件編碼錯誤，例：Request物件JSONBody編碼失敗
    public enum ErrorType: Int {
        case unknown = 0
        case mobileSystem
        case decoding
        case server
        case encoding
        case httpStatusCodeError
    }
}

// MARK: Equatable

extension ApiRequestError: Equatable {
    public static func == (lhs: ApiRequestError, rhs: ApiRequestError) -> Bool {
        return lhs.code == rhs.code && lhs.type == rhs.type
    }
}

// MARK: CustomStringConvertible

extension ApiRequestError: CustomStringConvertible {
    public var description: String {
        return "錯誤碼：\(code)  type：\(type) \n     錯誤訊息：\(message)"
    }
}
