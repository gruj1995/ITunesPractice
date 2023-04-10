//
//  ViewState.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Foundation

// MARK: - ViewState

enum ViewState {
    case loading
    case success
    case failed(error: Error)
    case none
}
