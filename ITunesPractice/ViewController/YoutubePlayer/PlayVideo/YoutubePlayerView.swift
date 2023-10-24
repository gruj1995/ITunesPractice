//
//  YoutubePlayerView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import UIKit
import YouTubeiOSPlayerHelper

protocol YoutubePlayerViewDelegate: AnyObject {
    /// 當前影片播放完畢
    func currentVideoDidFinish()
    /// 當前播放時間
    func didPlayTime(playTime: Float)
}

class YoutubePlayerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var delegate: YoutubePlayerViewDelegate? = nil
    private var playerViewDidBecomeReady: Bool = false
    private var isVideoPlaying: Bool = false

    /// youtube iframe 播放器參數文件： https://developers.google.com/youtube/player_parameters?playerVersion=HTML5&hl=zh-tw
    private var playerVars = [
        "autoplay": 1, // 自動播放影片(是:1,否:0)
        "playsinline": 1, // 在 HTML5 播放器中播放時，0：全屏模式播放, 1:内嵌播放
        "enablejsapi": 1  // 是否允許通過iFrame或JavaScript Player API控制播放器，預設為0
    ]

    lazy var playerView: YTPlayerView = {
        let view = YTPlayerView()
        view.delegate = self
        return view
    }()

    /// 設定UI
    private func setupUI() {
        addSubview(playerView)
        playerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    /// 下載影片
    func loadVideo(videoID: String) {
        if !playerViewDidBecomeReady {
            playerView.load(withVideoId: videoID, playerVars: playerVars)
        } else {
            playerView.cueVideo(byId: videoID, startSeconds: 0)
        }
    }

    /// 播放影片
    func playVideo() {
        playerView.playVideo()
        isVideoPlaying = true
    }

    /// 暫停影片
    func pauseVideo() {
        playerView.pauseVideo()
        isVideoPlaying = false
    }

    /// 停止影片
    func stopVideo() {
        playerView.stopVideo()
        isVideoPlaying = false
    }
}

// MARK: - YTPlayerViewDelegate

extension YoutubePlayerView: YTPlayerViewDelegate {

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerViewDidBecomeReady = true
        playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        delegate?.didPlayTime(playTime: playTime)
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {

    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .ended:
            delegate?.currentVideoDidFinish()
        case .cued:
            playVideo()
//        case .paused:
//            // 進入後台被暫停時讓音樂繼續播放
//            switch UIApplication.shared.applicationState {
//            case .background, .inactive:
//                playVideo()
//            default:
//                return
//            }
        default:
            break
        }
    }

    /// 調整影片解析度
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {

    }

//    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
//        let view = UIView()
//        view.addSubViewWithSameConstraint(smallLoadindView)
//        smallLoadindView.start(hasText: false)
//        return view
//    }

    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return .appColor(.gray6) ?? .darkGray
    }
}
