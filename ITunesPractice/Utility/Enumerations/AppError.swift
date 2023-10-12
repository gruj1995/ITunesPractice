//
//  AppError.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation

enum AppError: Error, LocalizedError {
    case noData
    case versionLastest
    case versionNotFound
    case decodeError
    case encodeError
    case unknown
    case failToGetAPIVersion
    case urlMissing
    case message(String)
    case noCadastral
    case missingRequiredParameters

    var errorDescription: String? {
        switch self {
        case .noData:
            return "無資料"
        case .versionLastest:
            return "版本確認"
        case .versionNotFound:
            return "API 版本號異常"
        case .decodeError:
            return "資料無法解析"
        case .encodeError:
            return "資料無法編碼"
        case .unknown:
            return "發生未知的錯誤"
        case .failToGetAPIVersion:
            return "取得API version時失敗"
        case .urlMissing:
            return "無法取得檔案路徑"
        case .message(let message):
            return message
        case .noCadastral:
            return "查無地籍資料"
        case .missingRequiredParameters:
            return "缺少必填參數"
        }
    }
}
