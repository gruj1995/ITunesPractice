//
//  VideoListViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import Combine
import Foundation

// MARK: - VideoListViewModel

class VideoListViewModel {
    // MARK: Lifecycle

    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    // MARK: Internal

    let app: AppModel = AppModel.shared

    var videoInfos: [VideoInfo] = []

    var searchTerm: String = ""

    var totalCount: Int {
        videoInfos.count
    }

    @Published var state: ViewState = .none

    func fetchVideos() {
        // 避免同時載入多次
        if case .loading = state { return }
        state = .loading

        NetworkManager.shared.searchYTVideos(term: searchTerm) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.videoInfos = items
                DispatchQueue.main.async {
                    self.state = .success
                }
            case .failure(let error):
                Logger.log(error.localizedDescription)
                DispatchQueue.main.async {
                    self.state = .failed(error: error)
                }
            }
        }
    }
}
