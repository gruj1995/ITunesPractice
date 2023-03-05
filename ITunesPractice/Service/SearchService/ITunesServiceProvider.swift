//
//  ITunesServiceProvider.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

public protocol ITunesServiceProvider {
    func search(term: String, limit: Int, offset: Int, completion: @escaping (Result<Bool, Error>) -> Void)
}
