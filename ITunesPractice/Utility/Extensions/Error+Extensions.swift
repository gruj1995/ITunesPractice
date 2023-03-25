//
//  Error+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import Foundation

extension Error {
    /// 如果是自訂的錯誤，印出對應的 errorDescription
    var unwrapDescription: String {
        switch self {
        case let musicPlayerError as MusicPlayerError:
            return musicPlayerError.errorDescription ?? ""
        default:
            return localizedDescription
        }
    }
}
