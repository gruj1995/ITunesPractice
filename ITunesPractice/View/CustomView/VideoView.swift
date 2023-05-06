//
//  VideoView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/24.
//

import AVFoundation
import UIKit

// MARK: - VideoView

// 參考： https://medium.com/@tarasuzy00/%E7%94%A8-swift-%E8%A3%BD%E4%BD%9C%E6%92%AD%E6%94%BE%E5%99%A8-ios-avplayer-%E6%95%99%E5%AD%B8-%E4%B8%80-%E8%A8%AD%E5%AE%9A%E4%B8%A6%E6%92%AD%E6%94%BE-avplayer-695dd145d9de

class VideoView: UIView {
    // MARK: Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        observePlayerDidFinishPlaying()
        // 讓影片填滿畫面
        playerLayer.videoGravity = .resizeAspectFill
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    func playMusicVideo(with url: URL) async {
        do {
            let html = try await fetchHTMLFromMVUrl(url)
            guard let urlString = KannaAdapter.shared.parseAppleMusicVideoHTML(html),
                  let url = URL(string: urlString)
            else {
                return
            }

            let asset = try await initPlayerAsset(with: url)
            let item = AVPlayerItem(asset: asset)
            // 必須在 main thread 執行
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: item)
                // 讓 MV 禁音
                self.player.isMuted = true
                self.observePlayerStatus()
            }
        } catch {
            Logger.log(error.unwrapDescription)
        }
    }

    /// 監聽播放狀態
    func observePlayerStatus() {
        guard let playerItem = player.currentItem else { return }
        observer = playerItem.observe(\.status, options: [.new]) { [weak self] playerItem, _ in
            guard let self else { return }
            switch playerItem.status {
            case .readyToPlay:
                Logger.log(".readyToPlay")
                self.player.play()
            case .failed:
                Logger.log(".failed \(String(describing: self.player.currentItem?.error))")
            case .unknown:
                Logger.log(".unknown")
            default:
                Logger.log("default")
            }
        }
    }

    // MARK: Private

    private var observer: NSKeyValueObservation?

    private var player: AVPlayer {
        get { playerLayer.player ?? AVPlayer() }
        set { playerLayer.player = newValue }
    }

    private func observePlayerDidFinishPlaying() {
        // 註冊播放完畢的觸發器
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    private func initPlayerAsset(with url: URL) async throws -> AVAsset {
        let asset = AVAsset(url: url)
        // Load an asset's suitability for playback.
        let isPlayable = try await asset.load(.isPlayable)
        if isPlayable {
            return asset
        } else {
            throw NSError(domain: "Asset is unplayable", code: -1, userInfo: nil)
        }
    }

    /// 從音樂 MV 的 url 取得 Apple music 網站的 HTML 資訊
    private func fetchHTMLFromMVUrl(_ url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Fetch HTML From MV Url Failed", code: -1, userInfo: nil)
        }
        return htmlString
    }

    /// 播放完畢後重複播放
    @objc
    private func playerDidFinishPlaying(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == player.currentItem
        else {
            return
        }
        player.seek(to: .zero)
        player.play()
    }
}
