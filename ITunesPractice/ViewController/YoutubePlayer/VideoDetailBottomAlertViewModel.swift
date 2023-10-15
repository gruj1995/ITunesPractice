//
//  VideoDetailBottomAlertViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Foundation

class VideoDetailBottomAlertViewModel: YTBaseBottomAlertViewModel {
    var totalCount: Int = 0
    var title: String = "說明"

    private(set) var videoDetailInfo: VideoDetailInfo

    init(videoDetailInfo: VideoDetailInfo) {
        self.videoDetailInfo = videoDetailInfo
    }

    func fetchData() {
        
    }
}
