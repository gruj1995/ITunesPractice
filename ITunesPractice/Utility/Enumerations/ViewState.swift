//
//  ViewState.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Foundation

// MARK: - ViewState

enum ViewState: Equatable {
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case let (.failed(error1), .failed(error2)):
            // 比较两个失败状态的错误
            return error1.localizedDescription == error2.localizedDescription
        case (.none, .none):
            return true
        default:
            return false
        }
    }

    case loading
    case success
    case failed(error: Error)
    case none
}
