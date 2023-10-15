//
//  YTBaseBottomAlertViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Foundation

protocol YTBaseBottomAlertViewModel {
    var title: String { get }
    var totalCount: Int { get }

    func fetchData()
}

