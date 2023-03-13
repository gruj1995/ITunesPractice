//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Combine
import UIKit

class SearchTestViewModel: PagingViewModel {

    @Published var items: [Track] = []

    var currentPage: Int = 0

    var hasMorePages: Bool = true

    var isLoading: Bool = false

    var pageSize: Int = 20

    func loadMoreItems(_ completion: @escaping (Result<[Track], Error>) -> Void) {
        guard !searchTerm.isEmpty else {
            items.removeAll()
            completion(.success([]))
            return
        }
        
        guard !isLoading else {
            return // 避免同時載入多次
        }

        guard hasMorePages else {
            return // 已經載入完畢
        }

        isLoading = true

        let offset = currentPage * pageSize
        let request = ITunesService.SearchRequest(term: searchTerm, limit: pageSize, offset: offset)
        // 已經在 main queue 收到 response
        request.fetchTracks { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                    let results = response.results
                    self.currentPage += 1
                    self.hasMorePages = results.count >= self.pageSize
                    self.items.append(contentsOf: results)
                    completion(.success(results))
            case .failure(let error):
                Logger.log(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    func loadMoreItemsIfNeeded(for indexPath: IndexPath) -> Bool {
        let buffer = 5 // 預先載入的緩衝區大小
        let thresholdIndex = items.count - buffer
        return indexPath.row >= thresholdIndex
//        if indexPath.row >= thresholdIndex {
//            loadMoreItemsSubject.send()
//        }
    }

    typealias Item = Track

    // MARK: Lifecycle

    init() {
        $searchTerm
            .debounce(for: 0.3, scheduler: RunLoop.main) // 延遲觸發搜索操作
            .removeDuplicates() // 避免在使用者輸入相同的搜索文字時重複執行搜索操作
            .sink { [weak self] keyWordValue in
                guard let self = self else { return }
                print(keyWordValue)
                self.loadMoreItems { _ in }
//                self?.search()
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var searchTerm: String = ""
    private(set) var selectedTrack: Track?

    /// 設定選取的歌曲
    func setSelectedTrack(forCellAt index: Int) {
        guard index < items.count else { return }
        selectedTrack = items[index]
    }

//    func search() {
//        guard !searchTerm.isEmpty else {
//            return tracks = []
//        }
//        // 防止重複呼叫
//        guard !isFetchInProgress else {
//            return
//        }
//        isFetchInProgress = true
//        print("__+++++ search")
//        let offset = (currentPage - 1) * pageSize
//        let request = ITunesService.SearchRequest(term: searchTerm, limit: pageSize, offset: offset)
//        request.fetchTracks { [weak self] result in
//            guard let self = self else { return }
//            self.isFetchInProgress = false
//            switch result {
//            case .success(let response):
//                DispatchQueue.main.async {
//                    if self.currentPage == 1 {
//                        self.tracks = response.results
//                    } else {
//                        self.tracks += response.results
//                    }
//                }
//                if response.results.count == self.pageSize {
//                    self.currentPage += 1
//                }
//            case .failure(let error):
//                Logger.log(error.localizedDescription)
//            }
//        }
//    }

    // MARK: Private

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []
}

// func search(){
//
//    //        request.send { (albums, response, error) in
//    //            if let error = error {
//    //                completion(.failure(error))
//    //            }
//    //            print("_+++ albums \(albums)")
//    //            completion(.success(true))
//    //        }
//    //
//    //        ApiSendHelper(request).send { result in
//    //            print("_+++ result \(result)")
//    //            switch result {
//    //            case .success:
//    //                let json = JSON(result)
//    //                print("_+++ \(result)")
//    //                completion(.success(true))
//    //            case .failure(let error):
//    //                completion(.failure(error))
//    //            }
//    //        }
// }
