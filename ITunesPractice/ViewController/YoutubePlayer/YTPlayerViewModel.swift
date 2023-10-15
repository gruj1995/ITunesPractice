//
//  YTPlayerViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation
import Combine

class YTPlayerViewModel: BaseListViewModel {

    var totalCount: Int {
        videoInfos.count
    }

    @Published var state: ViewState = .none
    var statePublisher: Published<ViewState>.Publisher { $state }

    /// 指定開啟的影片資訊
    private(set) var videoDetailInfo: VideoDetailInfo?
    private(set) var videoInfos: [VideoInfo] = []

    var videoId: String = ""
    var channelName: String = ""

    init(videoId: String, channelName: String) {
        self.videoId = videoId
        self.channelName = channelName
    }

    func reloadItems() {
        videoDetailInfo = nil
        videoInfos.removeAll()
        loadNextPage()
    }

    func loadNextPage() {
        guard !videoId.isEmpty, !channelName.isEmpty else {
            state = .failed(error: AppError.missingRequiredParameters)
            return
        }

        // 避免同時載入多次
        if case .loading = state { return }
        state = .loading

        NetworkManager.shared.getYTVideoInfoResponse(videoId: videoId, channelName: channelName) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.videoDetailInfo = response.data?.videoDetailInfo
                self.videoInfos = response.data?.recommendedVideos ?? []
                self.videoId = self.videoDetailInfo?.videoId ?? ""
                self.channelName = self.videoDetailInfo?.channelTitle ?? ""
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

    func setSelectedItem(index: Int) {
        guard let selectedVideo = videoInfos[safe: index] else {
            return
        }
        self.videoId = selectedVideo.videoId
        self.channelName = selectedVideo.channelTitle ?? ""
        reloadItems()
    }
}
