////
////  ChannelModel.swift
////  ITunesPractice
////
////  Created by 李品毅 on 2023/10/12.
////
//
//import Foundation
//
//class ChannelModel: EpisodeModelProtocol {
//
//    weak var delegate: VideoListModelDelegate?
//
//    private lazy var cache: VideoCacheManager = {
//        return VideoCacheManager.shared
//    }()
//
//    var videoList: [VideoInfo]? {
//        return cache.videoListInChannel[channelID]
//    }
//
//    /// 是否已經取到底
//    private var isLoadToEnd: Bool {
//        return cache.isVideoInChannelLoadToEnd[channelID] ?? false
//    }
//
//    /// 使否正在call api
//    private var isFetching: Bool = false
//
//    private let fetchCount: Int = 20
//
//    let channelID: String
//
//    /// 指定開啟的影片資訊
//    private var videoInfo: VideoInfo?
//
//    init(channelID: String, videoInfo: VideoInfo? = nil) {
//        self.channelID = channelID
//        self.videoInfo = videoInfo
//        self.insertVideoIfNeed()
//    }
//
//    /// 檢查是否有指定開啟的影片，有的話將影片插入至第一個
//    private func insertVideoIfNeed() {
//        guard let video = videoInfo else { return }
//        if cache.videoListInChannel[channelID] == nil {
//            cache.videoListInChannel[channelID] = []
//        }
//        cache.videoListInChannel[channelID]?.removeAll()
//        cache.videoListInChannel[channelID]?.insert(video, at: 0)
//    }
//
//    func isVideoListEmpty() -> Bool {
//        if let videoList = videoList,
//           videoList.count > 0 {
//            return false
//        }
//        return true
//    }
//
//    /// 是否是最後一支影片
//    func isLastVideo(index: Int) -> Bool {
//        if let videoCount = videoList?.count,
//           isLoadToEnd,
//           index == videoCount - 1 {
//            return true
//        }
//        return false
//    }
//
//    func getVideoInfo(at index: Int) -> VideoInfo? {
//        if let list = videoList,
//           list.indices.contains(index) {
//            return list[index]
//        }
//        return nil
//    }
//
//    func fetchVideoList(needReload: Bool) {
//        guard !isFetching else { return }
//        if needReload {
//            cache.isVideoInChannelLoadToEnd[channelID] = false
//            cache.lastGetPublishTimeInChannel[channelID] = nil
//            cache.videoListInChannel[channelID] = []
//        }
//
//        if isLoadToEnd {
//            return
//        }
//        isFetching = true
//        let time = cache.lastGetPublishTimeInChannel[channelID]
//        getChannelList(time: time) { [weak self] videoList in
//            guard let self = self else { return }
//            guard let videoList = videoList else {
//                self.delegate?.getVideoListFailed()
//                return
//            }
//            if videoList.count < self.fetchCount {
//                self.cache.isVideoInChannelLoadToEnd[self.channelID] = true
//            }
//            if self.cache.videoListInChannel[self.channelID] == nil {
//                self.cache.videoListInChannel[self.channelID] = []
//            }
//            self.cache.videoListInChannel[self.channelID]?.append(contentsOf: videoList)
//            if let time = videoList.last?.publishDate {
//                self.cache.lastGetPublishTimeInChannel[self.channelID] = Int(time)
//            }
//            self.delegate?.didGetVideoList()
//        }
//    }
//
//    /// 清除影片清單快取
//    func clearVideoCache(){
//        cache.videoListInChannel[channelID]?.removeAll()
//        cache.isVideoInChannelLoadToEnd[channelID] = false
//        cache.lastGetPublishTimeInChannel[channelID] = nil
//    }
//}
//
//extension ChannelModel {
//
//    func getChannelList(time: Int? = nil, completion: @escaping ([VideoInfo]?) -> Void) {
//        MoneyApiHelper.sharedInstance.getChannelVideoList(channelID: channelID, amount: fetchCount, time: time) { (isSuccess,error,videoInfos) in
//            if isSuccess{
//                completion(videoInfos)
//            }else{
//                completion(nil)
//            }
//        }
//    }
//}
//
