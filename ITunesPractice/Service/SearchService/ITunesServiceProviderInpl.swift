//
//  ITunesServiceProviderInpl.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

class ITunesServiceProviderInpl: ITunesServiceProvider {

    private let iTunesServiceProvider: ITunesServiceProvider
    
    init(iTunesServiceProvider: ITunesServiceProvider) {
        self.iTunesServiceProvider = iTunesServiceProvider
    }

    /// - Parameters:
    ///    - limit: 單次查詢回傳筆數上限
    ///    - offset: 偏移量， e.g. 全部12首歌 -> limit 設為 10，offset 設為 1 -> 回傳第 2~11 首
    func search(term: String, limit: Int, offset: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let request = ITunesService.SearchRequest(term: term, limit: limit, offset: offset)

        ApiSendHelper(request).send { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
