//
//  MusicPlayer.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import AVFoundation
import AVKit
import Combine
import Foundation
import MediaPlayer // MPVolumeView

// MARK: - MusicPlayer

class MusicPlayer: NSObject, MusicPlayerProtocol {

    // MARK: Lifecycle

    private override init() {
        super.init()
        setAVQueuePlayer()

        UIApplication.shared.beginReceivingRemoteControlEvents()
        //  設定背景&鎖定播放
        setupRemoteTransportControls()

        currentTrackIndex = 0

        // 觀察待播清單更新
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: .toBePlayedTracksDidChanged, object: nil)

        // 每首歌曲播放完畢時更新索引
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.nextTrack()
        }
    }

    // MARK: Internal

    static let shared = MusicPlayer()

    var cancellables: Set<AnyCancellable> = .init()

    var player: AVQueuePlayer = .init()

    // 是否隨機播放
    var isShuffleMode: Bool = false

    // 是否無限循環
    var isInfinityMode: Bool = false

    // 重複的模式
    var repeatMode: RepeatMode = .none

    // 播放速率下限
    let minPlaybackRate: Float = 0.5

    // 播放速率上限
    let maxPlaybackRate: Float = 2.0

    // 播放清單
    var tracks: [Track] {
        get { UserDefaults.standard.tracks }
        set { UserDefaults.standard.tracks = newValue }
    }

    var currentTrackIndex: Int {
        get { currentTrackIndexSubject.value }
        set {
            currentTrackIndexSubject.value = newValue
            // 設定背景當前播放資訊
            setupNowPlaying()
        }
    }

    // 是否正在播放
    var isPlaying: Bool {
        get { isPlayingSubject.value }
        set {
            isPlayingSubject.value = newValue

            if newValue {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    var currentTrack: Track? {
        guard tracks.indices.contains(currentTrackIndex) else {
            return nil
        }
        return tracks[currentTrackIndex]
    }

    // 當前播放進度（單位：秒）
    var currentPlaybackTime: Double? {
        get { timeSubject.value }
        set { timeSubject.value = newValue }
    }

    // 當前曲目總長度（單位：秒）
    var currentPlaybackDuration: Double? {
        player.currentItem?.duration.seconds
    }

    // 當前播放進度 Float 值
    var currentTimeFloatValue: Float {
        currentPlaybackTime?.floatValue ?? 0
    }

    // 當前曲目總長度 Float 值
    var totalDurationFloatValue: Float {
        currentPlaybackDuration?.floatValue ?? 1
    }

    // 指定播放速率
    // 0.0 暫停
    // 1.0 原始速率
    // 大於0快轉; 小於0倒轉
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

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        return currentTrackIndexSubject.eraseToAnyPublisher()
    }

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        return timeSubject.eraseToAnyPublisher()
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        return isPlayingSubject.eraseToAnyPublisher()
    }

    @objc
    func userDefaultsDidChange() {
        setAVQueuePlayer()
    }

    /// 在 AppDelegate 呼叫，讓 MusicPlayer 在開啟app時就建立
    func configure() {}

    // MARK: Private

    private var looper: AVPlayerLooper?

    // 用來控制系統音量（只使用它裡面的 slider ）
    private let mpVolumeView: MPVolumeView = .init()

    private var timeObserverToken: Any?

    private let currentTrackIndexSubject = CurrentValueSubject<Int, Never>(0)
    private let timeSubject = CurrentValueSubject<Double?, Never>(nil)
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)

    // 待播清單
    private var toBePlayedItems: [AVPlayerItem] = []

    private func setAVQueuePlayer() {
        // 移除時間觀察
        removeTimeObserver()

        // 建立 AVQueuePlayer 並設定播放清單
        toBePlayedItems = tracks.convertToPlayerItems()
        player = AVQueuePlayer(items: toBePlayedItems)

        // 新增時間觀察
        addTimeObserver()
    }

    private func addTimeObserver() {
        // 每秒發送 timescale 次監聽事件
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self, self.player.currentItem?.status == .readyToPlay else { return }
            let currentTime = max(time.seconds, 0) // 避免初始時出現負數秒數
            self.currentPlaybackTime = currentTime
        }
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    /// 播放指定索引的歌曲
    @discardableResult
    private func play(at index: Int) -> Bool {
        guard !tracks.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return false
        }
        guard tracks.isValidIndex(index) else {
            Utils.toast(MusicPlayerError.invalidIndex.unwrapDescription)
            return false
        }
        guard let audioURL = URL(string: tracks[index].previewUrl) else {
            Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
            return false
        }
        // 回到歌曲開頭
        seek(to: 0)

        let playItem = AVPlayerItem(url: audioURL)
        player.replaceCurrentItem(with: playItem)

        // 停止當前的循環
        if looper != nil {
            looper?.disableLooping()
            looper = nil
        }
        // 使用 AVPlayerLooper 實現單曲循環
        if repeatMode == .one {
            looper = AVPlayerLooper(player: player, templateItem: playItem)
        }

        currentTrackIndex = index
        return true
    }

    // MARK: 暫時關閉

    //    // 當前的播放狀態，包含暫停、等待播放指定曲目、播放中
    //    var playStatus: AVPlayer.TimeControlStatus {
    //        player.timeControlStatus
    //    }

    //    // 當前曲目剩餘時間（單位：秒）
    //    var currentPlaybackRemainingTime: Double? {
    //        guard let currentTime = currentPlaybackTime,
    //              let totalDuration = currentPlaybackDuration
    //        else {
    //            return nil
    //        }
    //        return totalDuration - currentTime
    //    }
}

// MARK: MusicPlayerControl

extension MusicPlayer {
    ///  播放當前曲目(從頭開始播放)
    func play() {
        let index = currentTrackIndex
        play(at: index)
        isPlaying = true
    }

    /// 暫停
    func pause() {
        isPlaying = false
    }

    /// 繼續播放
    func resume() {
        isPlaying = true
    }

    /// 停止播放(暫停並將時間設到歌曲開始)
    func stop() {
//        play(at: 0)
//        isPlaying = false
//        player.seek(to: CMTime.zero)
    }

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

    func seek(to time: Double, completionHandler: @escaping (Bool) -> Void) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime, completionHandler: completionHandler)
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
        isPlaying = true
    }

    /// 播放清單內的下一首
    @discardableResult
    func nextTrack() -> Bool {
        let index = currentTrackIndex
        var nextIndex: Int

        switch repeatMode {
        // 循環播放單曲
        case .one:
            nextIndex = currentTrackIndex
        // 循環播放全部/不循環播放
        case .all, .none:
            if isShuffleMode {
                // TODO: 隨機播放時原本的播放清單要怎麼處理？
                nextIndex = tracks.randomIndexExcluding(index)
            } else {
                nextIndex = currentTrackIndex + 1
                // 播放到最後一首時
                if nextIndex >= tracks.count {
                    playlistDidFinishPlaying()
                    return true
                }
            }
        }

        let isSuccess = play(at: nextIndex)
        return isSuccess
    }

    /// 播放清單內的上一首
    @discardableResult
    func previousTrack() -> Bool {
        let index = currentTrackIndex
        let previousIndex = isShuffleMode ? tracks.randomIndexExcluding(index) : index - 1
        let isSuccess = play(at: previousIndex)
        return isSuccess
    }

    // 移除所有播放清單中的歌曲
    func removeAllItems() {
        player.removeAllItems()
    }

    /// 播放清單內的歌曲都播放完畢
    private func playlistDidFinishPlaying() {
        // 重整播放清單
        setAVQueuePlayer()
        // 切回第一首歌開頭
        seek(to: 0)
        currentTrackIndex = 0

        if repeatMode == .all {
            isPlaying = true
        } else if repeatMode == .none {
            isPlaying = false
        }
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

extension Array where Element == Track {
    func convertToPlayerItems() -> [AVPlayerItem] {
        return compactMap { track -> AVPlayerItem? in
            guard let url = URL(string: track.previewUrl) else {
                return nil
            }
            return AVPlayerItem(url: url)
        }
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
