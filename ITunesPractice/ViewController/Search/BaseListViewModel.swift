//
//  BaseListViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Combine
import Foundation

protocol BaseListViewModel: AnyObject {
    var statePublisher: Published<ViewState>.Publisher { get }
    var totalCount: Int { get }

    func loadNextPage()
    func reloadItems()
}
