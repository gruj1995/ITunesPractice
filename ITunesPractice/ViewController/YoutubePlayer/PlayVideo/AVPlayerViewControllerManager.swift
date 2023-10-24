//
//  AVPlayerViewControllerManager.swift
//  XCDYouTubeKit iOS Demo
//
//  Created by Soneé John on 10/29/19.
//  Copyright © 2019 Cédric Luthi. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer
import XCDYouTubeKit

@objcMembers
class AVPlayerViewControllerManager: NSObject {

    static let shared = AVPlayerViewControllerManager()

    var lowQualityMode = false

    dynamic var duration: Float = 0

    var didPlayToEndTime: (() -> Void)?

    weak var videoViewController: UIViewController?

    var video: XCDYouTubeVideo? {
        didSet {
            guard let video = video else { return }
            guard lowQualityMode == false else {
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else {
                    Logger.log("No stream URL")
                    return
                }
                self.player = AVPlayer(url: streamURL)
                self.controller.player = self.player
                return
            }
            guard let streamURL = video.streamURL else {
                Logger.log("No stream URL")
                return
            }
            self.player = AVPlayer(url: streamURL)
            self.controller.player = self.player
        }
    }

    var player: AVPlayer? {
        didSet {
//            if let playerRateObserverToken = playerRateObserverToken {
//                playerRateObserverToken.invalidate()
//                self.playerRateObserverToken = nil
//            }
//
//            self.playerRateObserverToken = player?.observe(\.rate) { (_, _) in
//                self.updatePlaybackRateMetadata()
//            }
//
//            guard let video = self.video else { return }
//            if let token = timeObserverToken {
//                oldValue?.removeTimeObserver(token)
//                timeObserverToken = nil
//            }
//            self.setupRemoteTransportControls()
//            self.updateGeneralMetadata(video: video)
//            self.updatePlaybackDuration()
        }
    }

   lazy var controller: AVPlayerViewController = {
        let controller = AVPlayerViewController()
//        if #available(iOS 10.0, *) {
//            controller.updatesNowPlayingInfoCenter = false
//        }
        return controller
    }()

    override init() {
        super.init()
        setObserver()
    }

    func setObserver() {
        // 每首歌曲播放完畢時更新索引
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)

        // 處理音頻中斷事件
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: nil) { (notification) in

            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }

            if type == .began {
                self.player?.pause()
            } else if type == .ended {
                guard ((try? AVAudioSession.sharedInstance().setActive(true)) != nil) else { return }
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                guard options.contains(.shouldResume) else { return }
                self.player?.play()
            }
        }
    }

    func playVideo(_ videoID: String, _ completion: @escaping ((XCDYouTubeVideo?, Error?) -> Void)) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoID, completionHandler: completion)
    }

    func clear() {
        videoViewController = nil
        player = nil
        controller.player = player
    }

    // MARK: 背景播放相關

    func disconnectPlayer() {
        controller.player = nil
    }

    func reconnectPlayer() {
        guard let _ = videoViewController else {
            return
        }
        controller.player = player
    }

    // MARK: Private

//    fileprivate var playerRateObserverToken: NSKeyValueObservation?
//    fileprivate var timeObserverToken: Any?
//    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
//
//    fileprivate func setupRemoteTransportControls() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//        commandCenter.playCommand.addTarget { [unowned self] _ in
//            if self.player?.rate == 0.0 {
//                self.player?.play()
//                return .success
//            }
//            return .commandFailed
//        }
//
//        commandCenter.pauseCommand.addTarget { _ in
//            if self.player?.rate == 1.0 {
//                self.player?.pause()
//                return .success
//            }
//            return .commandFailed
//        }
//    }
//
//    fileprivate func updateGeneralMetadata(video: XCDYouTubeVideo) {
//        guard player?.currentItem != nil else {
//            nowPlayingInfoCenter.nowPlayingInfo = nil
//            return
//        }
//
//        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
//        let title = video.title
//
//        if let thumbnailURL = video.thumbnailURLs?.first {
//            URLSession.shared.dataTask(with: thumbnailURL) { (data, _, error) in
//                guard error == nil else { return }
//                guard data != nil else { return }
//                guard let image = UIImage(data: data!) else { return }
//                let artwork = MPMediaItemArtwork(image: image)
//                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
//                self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
//            }.resume()
//        }
//
//        nowPlayingInfo[MPMediaItemPropertyTitle] = title
//        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
//    }
//
//    fileprivate func updatePlaybackDuration() {
//        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//
//        timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) {  [weak self] _ in
//            guard let self,
//                  let player = self.player,
//                  let currentItem = player.currentItem
//            else {
//                return
//            }
//
//            var nowPlayingInfo = self.nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
//            self.duration = Float(CMTimeGetSeconds(currentItem.duration))
//            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
//            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentItem.currentTime())
//            self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
//        }
//    }
//
//    fileprivate func updatePlaybackRateMetadata() {
//        guard player?.currentItem != nil else {
//            duration = 0
//            nowPlayingInfoCenter.nowPlayingInfo = nil
//            return
//        }
//
//        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player!.rate
//        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = player!.rate
//    }
}

extension AVPlayerViewControllerManager {
    /// 歌曲播放完畢準備進入下一首(自動接續)
    @objc
    private func playerItemDidPlayToEndTime(_ notification: Notification) {
        // 避免誤收到其他 player 的通知
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == player?.currentItem else {
            return
        }
        didPlayToEndTime?()
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
