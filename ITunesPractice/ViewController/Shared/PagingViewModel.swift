//
//  PagingViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/5.
//

import Foundation

// 支援分頁 load 資料
protocol PagingViewModel: AnyObject {
    associatedtype Item

    var items: [Item] { get }

    var currentPage: Int { get set }

    var hasMorePages: Bool { get set }

    var isLoading: Bool { get set }

    var pageSize: Int { get }  // 每次請求資料筆數上限

    func loadMoreItems(_ completion: @escaping (Result<[Item], Error>) -> Void)
}
