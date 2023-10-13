////
////  VideoListModel.swift
////  ITunesPractice
////
////  Created by 李品毅 on 2023/10/12.
////
//
//import Foundation
//
//protocol VideoListModelDelegate: AnyObject {
//    func getVideoListFailed()
//    func didGetVideoList()
//}
//
//class VideoListModel: EpisodeModelProtocol {
//    weak var delegate: VideoListModelDelegate?
//
//    /// 其他分類一次取影片的數量
//    private let fetchCount: Int = 20
//
//    /// 全部頁籤一次取標籤影片的數量
//    private let allTagFetchCount: Int = 30
//
//    /// 全部頁籤一次取caneel影片的數量
//    private let channelFetchCount: Int = 3
//
//    /// remoteConfig設定要過濾的頻道ID
//    private lazy var filterChannelIDs: [String] = {
//        return RemoteConfigManager.getFilterChannelIDs()
//    }()
//
////    private lazy var apiEngine: ApiEngine = {
////        return ApiEngine.shared
////    }()
//
//    private lazy var cache: VideoCacheManager = {
//        return VideoCacheManager.shared
//    }()
//
//    /// 影片列表
//    var videoList: [VideoInfo]? {
//        if tag == .all {
//            return cache.combinedVideoList
//        }
//        return cache.tagVideoList[tag]
//    }
//
//    /// 是否已經取到底
//    private var isLoadToEnd: Bool {
//        return cache.isLoadToEnd[tag] ?? false
//    }
//
//    /// 使否正在call api
//    private var isFetching: Bool = false
//
//    private let tag: VideoTagType
//
//    /// 指定開啟的影片資訊
//    private var videoInfo: VideoInfo?
//
//    init(tag: VideoTagType, videoInfo: VideoInfo? = nil) {
//        self.videoInfo = videoInfo
//        self.tag = tag
//        self.insertVideoIfNeed()
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
//    /// 取得指定index的影片資訊
//    func getVideoInfo(at index: Int) -> VideoInfo? {
//        if let list = videoList,
//           list.indices.contains(index) {
//            return list[index]
//        }
//        return nil
//    }
//
//    /// 取影片列表
//    func fetchVideoList(needReload: Bool) {
//        guard !isFetching else { return }
//        if needReload {
//            cache.isLoadToEnd[tag] = false
//            cache.tagLastGetPublishTime[tag] = nil
//            cache.tagVideoList[tag] = []
//        }
//
//        if isLoadToEnd {
//            return
//        }
//        isFetching = true
//        switch tag {
//        case .all:
//            getAllVideoList { isSuccess in
//                self.completionHandler(isSuccess: isSuccess)
//            }
//        default:
//            return
////            getTagVideoList(fetchCount: fetchCount){ isSuccess in
////                self.completionHandler(isSuccess: isSuccess)
////            }
//        }
//    }
//
//    // MARK: - private method
//
//    /// 檢查是否有指定開啟的影片，有的話將影片插入至第一個
//    private func insertVideoIfNeed() {
//        guard let video = videoInfo else { return }
//        switch tag {
//        case .all:
//            if cache.combinedVideoList == nil {
//                cache.combinedVideoList = []
//            }
//            cache.combinedVideoList?.insert(video, at: 0)
//        default:
//            if cache.tagVideoList[tag] == nil {
//                cache.tagVideoList[tag] = []
//            }
//            cache.tagVideoList[tag]?.insert(video, at: 0)
//        }
//    }
//
//    /// api取得結果
//    private func completionHandler(isSuccess: Bool) {
//        isFetching = false
//        if isSuccess {
//            delegate?.didGetVideoList()
//        } else {
//            cache.isLoadToEnd[tag] = true
//            delegate?.getVideoListFailed()
//        }
//    }
//
//    /// 取得全部頁籤的影片列表(需要取得指定頻道+指定分類API)
//    private func getAllVideoList(completion: @escaping (Bool)->Void) {
//        var resultIsSuccess: Bool = false
//        let group = DispatchGroup()
////        group.enter()
////        getTagVideoList(fetchCount: allTagFetchCount) { isSuccess in
////            resultIsSuccess = isSuccess
////            group.leave()
////        }
//        group.enter()
//        getChannelVideoList(fetchCount: channelFetchCount) { isSuccess in
//            group.leave()
//        }
//        group.notify(queue: .main) { [weak self] in
//            self?.combineVideoList()
//            completion(resultIsSuccess)
//        }
//    }
//
////    /// 取得指定分類標籤的影片列表
////    private func getTagVideoList(fetchCount: Int, completion: @escaping (Bool)->Void) {
////        let tagTime = cache.tagLastGetPublishTime[tag]
////        getVideoList(amount: fetchCount, time: tagTime) { [weak self] videoList in
////            guard let self = self,
////                  let videoList = videoList else {
////                completion(false)
////                return
////            }
////            self.setCache(type: .tag(type: self.tag), list: videoList)
////            completion(true)
////        }
////    }
//
//    /// 取得指定頻道ID的影片列表
//    private func getChannelVideoList(fetchCount: Int, completion: @escaping (Bool)->Void) {
//        let channelID = cache.litsaiheneasyChannelID
//        let channelTime = cache.channelLastGetPublishTime[channelID]
//        getChannelList(channelID: channelID, amount: fetchCount, time: channelTime) { [weak self] videoList in
//            guard let self = self,
//                  let videoList = videoList else {
//                completion(false)
//                return
//            }
//            self.setCache(type: .channel(id: channelID), list: videoList)
//            completion(true)
//        }
//    }
//
//    private func setCache(type: VideoListType, list: [VideoInfo]) {
//        setIfLoadToEnd(type: type, count: list.count)
//        setListToCache(type: type, list: list)
//        setLastGetPublishTime(type: type, lastVideoInfo: list.last)
//    }
//
//    /// 判斷是否取到底
//    private func setIfLoadToEnd(type: VideoListType, count: Int) {
//        guard count < fetchCount else { return }
//        switch type {
//        case .tag(let tagType):
//            cache.isLoadToEnd[tagType] = true
//        case .channel(let id):
//            cache.isChannelInAllLoadToEnd[id] = true
//        }
//    }
//
//    /// 將影片列表存入快取
//    private func setListToCache(type: VideoListType, list: [VideoInfo]) {
//        switch type {
//        case .tag(let tagType):
//            if cache.tagVideoList[tagType] == nil {
//                cache.tagVideoList[tagType] = []
//            }
//            let newList = filterChannelIDs(list)
//            cache.tagVideoList[tagType]?.append(contentsOf: newList)
//        case .channel(let id):
//            if cache.channelVideoList[id] == nil {
//                cache.channelVideoList[id] = []
//            }
//            cache.channelVideoList[id]?.append(contentsOf: list)
//        }
//
//    }
//
//    /// 設定最後一筆發佈時間
//    private func setLastGetPublishTime(type: VideoListType, lastVideoInfo: VideoInfo?) {
//        guard let time = lastVideoInfo?.publishDate else { return }
//        switch type {
//        case .tag(let tagType):
//            cache.tagLastGetPublishTime[tagType] = Int(time)
//        case .channel(let id):
//            cache.channelLastGetPublishTime[id] = Int(time)
//        }
//    }
//
//    /// 過濾不要的ChannelID
//    private func filterChannelIDs(_ list: [VideoInfo]) -> [VideoInfo] {
//        var newList: [VideoInfo] = []
//        for video in list {
//            if !filterChannelIDs.contains(video.channel.channelID) {
//                newList.append(video)
//            }
//        }
//        return newList
//    }
//
//    /// 合併兩個影片列表(0,35,70...放channel，其餘放tag)
//    private func combineVideoList() {
//        if cache.combinedVideoList == nil {
//            cache.combinedVideoList = []
//        }
//        cache.combinedVideoList?.removeAll()
//        let id = cache.litsaiheneasyChannelID
//        guard var tagVideoList = cache.tagVideoList[tag],
//              !tagVideoList.isEmpty else { return }
//        guard var channelVideoList = cache.channelVideoList[id],
//              !channelVideoList.isEmpty else {
//            cache.combinedVideoList = tagVideoList
//            return
//        }
//        let groupCount = (tagVideoList.count - 1) / 34 + 1
//        for _ in 0..<groupCount {
//            if let first = channelVideoList.first {
//                cache.combinedVideoList?.append(first)
//                channelVideoList.removeFirst()
//            }
//            let subList = Array(tagVideoList.prefix(34))
//            cache.combinedVideoList?.append(contentsOf: subList)
//            tagVideoList.removeFirst(subList.count)
//        }
//    }
//
//}
//
//extension VideoListModel {
//
////    func getVideoList(amount: Int, time: Int? = nil, completion: @escaping ([VideoInfo]?) -> Void) {
////        apiEngine.getCategoryVideoList(ids: tag.ids, amount: amount, time: time) { result in
////            switch result {
////            case .failure(_):
////                completion(nil)
////            case .success(let videoList):
////                completion(videoList)
////            }
////        }
////    }
//
////    func getVideoList(amount: Int, time: Int? = nil, completion: @escaping ([VideoInfo]?) -> Void) {
////        MoneyApiHelper.sharedInstance.getChannelVideoList(channelID: cache.litsaiheneasyChannelID, cateIDs: tag.ids, amount: amount, time: time) { (isSuccess,error,videoInfos) in
////            if isSuccess{
////                completion(videoInfos)
////            }else{
////                completion(nil)
////            }
////        }
////    }
//
//    func getChannelList(channelID: String, amount: Int, time: Int? = nil, completion: @escaping ([VideoInfo]?) -> Void) {
//        MoneyApiHelper.sharedInstance.getChannelVideoList(channelID: channelID, amount: amount, time: time) { (isSuccess,error,videoInfos) in
//            if isSuccess{
//                completion(videoInfos)
//            }else{
//                completion(nil)
//            }
//        }
//    }
//}
//
