//
//  MusicPlayer.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import AVFoundation
import AVKit
import Foundation
import Combine
import MediaPlayer // MPVolumeView

// MARK: - MusicPlayer

class MusicPlayer: MusicPlayerProtocol {

    // MARK: Lifecycle

    private init() {
        initQueuePlayer()
        addTimeObserver()
    }

    // MARK: Internal

    static let shared = MusicPlayer()

    /// 在 AppDelegate 呼叫，讓 MusicPlayer 在開啟app時就建立
    func configure() {}

    private let mpVolumeView: MPVolumeView = MPVolumeView()

    // 播放清單
    var tracks: [Track] = []

    var currentTrackIndex: Int? 

    // 是否隨機播放
    var isShuffleMode: Bool = false

    // 重複的模式
    var repeatMode: RepeatMode = .none

    // 播放速率下限
    let minPlaybackRate: Float = 0.5

    // 播放速率上限
    let maxPlaybackRate: Float = 2.0

    var player: AVQueuePlayer!

    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    // 當前的播放狀態，包含暫停、等待播放指定曲目、播放中
    var playStatus: AVPlayer.TimeControlStatus {
        player.timeControlStatus
    }

    var currentTrack: Track? {
        guard let index = currentTrackIndex else { return nil }
        return tracks[index]
    }

    // 當前播放進度（單位：秒）
    var currentPlaybackTime: Double? {
        timeSubject.value
    }

    // 當前曲目總長度（單位：秒）
    var currentPlaybackDuration: Double? {
        player.currentItem?.duration.seconds
    }

    // 當前曲目剩餘時間（單位：秒）
    var currentPlaybackRemainingTime: Double? {
        guard let currentTime = currentPlaybackTime,
              let totalDuration = currentPlaybackDuration
        else {
            return nil
        }
        return totalDuration - currentTime
    }

    // 指定播放速率，0.0 表示暫停，1.0 表示播放原始速率
    var playbackRate: Float {
        get { player.rate }
        set {
            // 根據文件說明，iOS 16前需要在主線程上訪問 rate
            DispatchQueue.main.async { [weak self] in
                self?.player.rate = newValue
            }
        }
    }

    // 系統音量，取值範圍為 0.0 到 1.0 之間
    var volume: Float {
        get {
            guard let slider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else {
                return 0
            }
            return slider.value
        }
        set {
            guard let slider = mpVolumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else {
                return
            }
            DispatchQueue.main.async {
                slider.value = newValue
            }
        }
    }

    // 是否靜音
    var isMuted: Bool {
        get { player.isMuted }
        set { player.isMuted = newValue }
    }

    /// 上首歌曲播放結束，判斷播放下一首的邏輯
    func playNextTrack() throws {
        guard !tracks.isEmpty else {
            throw MusicPlayerError.emptyPlaylist
        }

        var nextIndex: Int
        switch repeatMode {
        case .all:
            nextIndex = (currentTrackIndex ?? -1) + 1
            if !tracks.isValidIndex(nextIndex) {
                nextIndex = 0
            }
        case .one:
            nextIndex = currentTrackIndex ?? 0
        case .none:
            nextIndex = (currentTrackIndex ?? -1) + 1
            if !tracks.isValidIndex(nextIndex) {
                stop()
                return
            }
        }

        player.advanceToNextItem()
//        play(at: nextIndex)
    }

    // MARK: Private

    private func initQueuePlayer() {
        // 取得儲存在本地的播放清單資料
        tracks = UserDefaults.standard.tracks

        // 將 tracks 陣列中的每個元素轉換成 AVPlayerItem 並加入到 playerItems 陣列中
        let playerItems = tracks.compactMap { track -> AVPlayerItem? in
            guard let url = URL(string: track.previewUrl) else {
                return nil
            }
            return AVPlayerItem(url: url)
        }

        // 建立 AVQueuePlayer 並將 playerItems 陣列設定為播放清單
        player = AVQueuePlayer(items: playerItems)
    }

    /// 播放指定索引的歌曲
    private func play(at index: Int) {
        guard !tracks.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return
        }
        guard tracks.isValidIndex(index) else {
            Utils.toast(MusicPlayerError.invalidIndex.unwrapDescription)
            return
        }
        guard let audioURL = URL(string: tracks[index].previewUrl) else {
            Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
            return
        }

        let playerItem = AVPlayerItem(url: audioURL)
//        player.replaceCurrentItem(with: playerItem)
        player.insert(playerItem, after: nil)
        // TODO: 確認要哪一個
//        // 播放下一首
//        player.advanceToNextItem()
        isPlaying = true
    }

    private var timeObserverToken: Any?

    private func addTimeObserver() {
        // 每 0.1 秒發送一次監聽事件
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.player.currentItem?.status == .readyToPlay {
                self.timeSubject.send(self.player.currentItem?.currentTime().seconds)
            }
        }
    }

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        return timeSubject.eraseToAnyPublisher()
    }

    private let timeSubject = CurrentValueSubject<Double?, Never>(nil)
}

// MARK: MusicPlayerControl

extension MusicPlayer {
    ///  播放當前曲目(從頭開始播放)
    func play() {
        guard let index = currentTrackIndex else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return
        }
        play(at: index)
    }

    /// 暫停
    func pause() {
        isPlaying = false
    }

    /// 繼續播放
    func resume() {
        isPlaying = true
    }

    /// 停止播放(清除目前播放的)
    func stop() {
        isPlaying = false
        player.replaceCurrentItem(with: nil)
    }

//    /// 停止播放(暫停並將時間設到歌曲開始)
//    func stop() {
//        player.pause()
//        isPlaying = false
//        player.seek(to: CMTime.zero)
//    }

    /**
     搜尋至指定時間位置

     @param time 指定時間值
     如果傳入的 time 值超出了歌曲的總時長，那麼播放器會自動將時間調整到歌曲的結尾，也就是最大值。
     如果傳入的 time 值小於 0，則會將時間調整到歌曲的開頭，也就是最小值
     */
    func seek(to time: Double) {
        // preferredTimescale 為時間尺度，表示一秒有多少幀，即 1 秒 = 1000/1000 秒
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime)
    }
}

// MARK: MusicPlayerPlaylistControl

extension MusicPlayer {
    /// 播放指定曲目
    func play(track: Track) {
        guard let index = tracks.firstIndex(of: track) else {
            Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
            return
        }
        play(at: index)
    }

    /// 播放清單內的下一首
    func nextTrack() {
        player.advanceToNextItem()
//        guard let index = currentTrackIndex else {
//            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
//            return
//        }
//        let nextIndex = isShuffleMode ? tracks.randomIndexExcluding(index) : index + 1
//        play(at: nextIndex)
    }

    /// 播放清單內的上一首
    func previousTrack() {
        guard let index = currentTrackIndex else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return
        }
        // 前面還有歌時
        if index > 0 {
            let items = player.items()
            let previousItem = items[index - 1]
            player.seek(to: CMTime.zero)
            player.replaceCurrentItem(with: previousItem)
            player.play()
        }
//        let previousIndex = isShuffleMode ? tracks.randomIndexExcluding(index) : index - 1
//        play(at: previousIndex)
    }

    // 移除所有播放清單中的歌曲
    func removeAllItems() {
        player.removeAllItems()
    }
}

// MARK: MusicPlayerSpeedControl

extension MusicPlayer {
    /// 快轉
    func fastForward() {
        // 越來越快直到上限
        let newFastForwardRate = min(playbackRate + 0.1, maxPlaybackRate)
        playbackRate = newFastForwardRate
    }

    /// 倒帶
    func rewind() {
        // 越來越慢直到下限
        let newRewindRate = max(playbackRate - 0.1, minPlaybackRate)
        playbackRate = newRewindRate
    }
}

// MARK: MusicPlayerShuffleControl

extension MusicPlayer {
    func toggleShuffleMode() {
        isShuffleMode.toggle()
    }

    func shuffle() {
        isShuffleMode = true
    }

    func unshuffle() {
        isShuffleMode = false
    }
}

// MARK: MusicPlayerRepeatControl

extension MusicPlayer {
    func repeatOne() {
        repeatMode = .one
    }

    func repeatAll() {
        repeatMode = .all
    }

    func repeatNone() {
        repeatMode = .none
    }
}

/**
 在音樂播放器中，RepeatMode和Shuffle通常是獨立的選項，可以搭配使用，也可以單獨使用。

 如果要同時使用RepeatMode和Shuffle，一般的做法是讓RepeatMode先生效，接著再套用Shuffle。這樣做可以確保即使在隨機播放模式下，也會先以指定的循環模式來循環播放歌曲，例如：

 循環播放當前歌曲：設置RepeatMode為RepeatOne。
 循環播放整個清單：設置RepeatMode為RepeatAll。
 不循環播放：設置RepeatMode為RepeatNone，同時設置Shuffle為Unshuffle。
 在這些情況下，即使設置了Shuffle，也會優先使用RepeatMode設置的循環模式。

 如果使用者想要在隨機播放模式下使用RepeatMode，例如循環播放當前歌曲，可以將RepeatMode設置為RepeatOne，同時設置Shuffle為Shuffle，這樣在隨機播放模式下，播放完當前歌曲後，會自動播放下一首隨機歌曲，但是當再次回到當前歌曲時，會繼續循環播放該歌曲，而不會再次隨機選擇下一首歌曲。
 */

// player.addBoundaryTimeObserver  傳入指定時間(陣列)要進行的行為

