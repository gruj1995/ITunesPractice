////
////  EpisodeModelProtocol.swift
////  ITunesPractice
////
////  Created by 李品毅 on 2023/10/12.
////
//
//import Foundation
//
//protocol EpisodeModelProtocol: AnyObject {
//
//    var delegate: VideoListModelDelegate? { get set }
//
//    /// 影片列表
//    var videoList: [VideoInfo]? { get }
//
//    /// 取得指定index的影片資訊
//    func getVideoInfo(at index: Int) -> VideoInfo?
//
//    /// 是否是最後一支影片
//    func isLastVideo(index: Int) -> Bool
//
//    /// 取影片列表
//    func fetchVideoList(needReload: Bool)
//}
//
