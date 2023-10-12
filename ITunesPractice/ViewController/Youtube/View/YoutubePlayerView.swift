//
//  YoutubePlayerView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import UIKit
import YouTubeiOSPlayerHelper

protocol YoutubePlayerViewDelegate: AnyObject {
    func currentVideoDidFinish()
    func didPlayTime(playTime: Float)
}

class YoutubePlayerView: UIView {

//    private lazy var smallLoadindView: SmallLoadingView = {
//        return SmallLoadingView()
//    }()

    lazy var playerView: YTPlayerView = {
        let view = YTPlayerView()
        view.delegate = self
        return view
    }()

    lazy var topMaskView: UIView = {
        return UIView()
    }()

    lazy var bottomMaskView: UIView = {
        return UIView()
    }()

    private var playerViewDidBecomeReady: Bool = false

    private var isVideoPlaying: Bool = false

    /// autoplay: 自動播放影片(是:1,否:0)
    /// disablekb: 支持鍵盤控制鍵(是:0,否:1)
    /// fs：播放器中顯示全屏按鈕(是:1,否:0)
    /// rel：視頻播放結束一定會顯示相關視頻(不同：1,同頻道：0)
    /// playsinline：在 HTML5 播放器中播放時，0：全屏模式播放, 1:内嵌播放
    private var playerVars = ["autoplay": 1,
                              "controls": 1,
                              "disablekb": 1,
                              "rel": 0,
                              "playsinline": 1]

    weak var delegate: YoutubePlayerViewDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 設定UI
    private func setupUI() {
        addSubview(playerView)
        playerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

//        addSubview(topMaskView)
//        topMaskView.snp.makeConstraints {
//            $0.leading.equalTo(playerView.snp.leading)
//            $0.trailing.equalTo(playerView.snp.trailing)
//            $0.top.equalTo(playerView.snp.top)
//            $0.height.equalTo(57)
//        }
//
//        addSubview(bottomMaskView)
//        bottomMaskView.snp.makeConstraints {
//            $0.trailing.equalTo(playerView.snp.trailing).offset(-55)
//            $0.bottom.equalTo(playerView.snp.bottom)
//            $0.height.equalTo(40)
//            $0.width.equalTo(70)
//        }
    }

    /// 加載影片
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
        default:
            break
        }
    }

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
