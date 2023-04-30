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

/**
    - 上一曲
        - 待播清單內上一首，如果到第一首就不再往前
    - 下一曲
        - 待播清單內下一首，如果到底會輪到第一首
        - 音樂播放超過5秒，在播放結束或點擊下一曲時加入播放紀錄
    - 待播清單內的不會刪除，播放清單頁展示 displayPlaylist
 */

class MusicPlayer: NSObject, MusicPlayerProtocol {
    // MARK: Lifecycle

    override init() {
        super.init()
        resetPlayerItem(track: currentTrack)
        setupRemoteControl()
        setupObservers()
    }

    // MARK: Internal

    static let shared = MusicPlayer()
    var player: AVPlayer = .init()
    var cancellables: Set<AnyCancellable> = .init()

    // 展示用的播放清單
    var displayPlaylist: [Track] {
        displayIndices.map { playlist[$0] }
    }

    var currentTrack: Track? {
        guard playlist.indices.contains(currentTrackIndex) else { return nil }
        return playlist[currentTrackIndex]
    }

    var currentTrackIndex: Int {
        get { UserDefaults.currentTrackIndex }
        set {
            currentTrackIndexSubject.value = newValue
            UserDefaults.currentTrackIndex = newValue
            // 設定背景當前播放資訊
            setupNowPlaying()
        }
    }

    // 播放紀錄
    var playedTracks: [Track] {
        get { UserDefaults.playedTracks }
        set { UserDefaults.playedTracks = newValue }
    }

    // 是否隨機播放
    var isShuffleMode: Bool {
        get { UserDefaults.isShuffleMode }
        set {
            UserDefaults.isShuffleMode = newValue
            toggleShuffleMode()
        }
    }

    // 是否無限循環
    var isInfinityMode: Bool {
        get { UserDefaults.isInfinityMode }
        set { UserDefaults.isInfinityMode = newValue }
    }

    // 重複的模式
    var repeatMode: RepeatMode {
        get { UserDefaults.repeatMode }
        set { UserDefaults.repeatMode = newValue }
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
    // - 0: 暫停, 1: 原始速率
    // - 大於0: 快轉, 小於0: 倒轉
    var playbackRate: Float {
        get { player.rate }
        set {
            // 根據文件說明，iOS 16前需要在主線程上訪問 rate
            DispatchQueue.main.async {
                self.player.rate = newValue
            }
        }
    }

    // 系統音量，取值範圍為 0.0 到 1.0 之間
    var volume: Float {
        get { mpVolumeView.volumeSlider?.value ?? 0 }
        set {
            guard let slider = mpVolumeView.volumeSlider else { return }
            DispatchQueue.main.async {
                slider.value = newValue
                self.volumeSubject.value = newValue // 將新的音量值發送到 volumeSubject 中
            }
        }
    }

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        currentTrackIndexSubject.eraseToAnyPublisher()
    }

    var playbackTimePublisher: AnyPublisher<Double?, Never> {
        timeSubject.eraseToAnyPublisher()
    }

    var volumePublisher: AnyPublisher<Float, Never> {
        volumeSubject.eraseToAnyPublisher()
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }

    var isShuffleModePublisher: AnyPublisher<Bool, Never> {
        isShuffleModeSubject.eraseToAnyPublisher()
    }

    // 播放清單
    var playlist: [Track] {
        get { UserDefaults.mainPlaylist }
        set { UserDefaults.mainPlaylist = newValue }
    }

    // MARK: Player

    /// 在 AppDelegate 呼叫，讓 MusicPlayer 在開啟app時就建立
    func configure() {}

    /// 選中的待播清單項目
    func setCurrentTrackIndex(to index: Int) {
        let trackIndex = displayIndices[index]
        guard playlist.indices.contains(trackIndex) else { return }
        currentTrackIndex = trackIndex
    }

    /// 取代正播放的音樂
    func replaceCurrentTrack(_ track: Track) {
        if playlist.isEmpty {
            playlist.append(track)
        } else {
            addPlayRecordIfNeeded()
            let newIndex = currentTrackIndex + 1
            playlist.insert(track, at: newIndex)
            currentTrackIndex = newIndex
            updateDisplayIndices()
        }
    }

    /// 加到待播清單首項
    func insertTrackToPlaylist(_ track: Track) {
        if playlist.isEmpty {
            playlist.append(track)
        } else {
            let newIndex = currentTrackIndex + 1
            playlist.insert(track, at: newIndex)
            updateDisplayIndices()
        }
    }

    /// 加到待播清單末項
    func addTrackToPlaylist(_ track: Track) {
        playlist.append(track)
    }

    /// 刪除指定的待播清單歌曲
    func removeTrackFromDisplayPlaylist(at index: Int) {
        let trackIndex = displayIndices[index]
        guard playlist.indices.contains(trackIndex) else { return }
        playlist.remove(at: trackIndex)
        updateDisplayIndices()
    }

    /// 刪除指定的播放紀錄
    func removeFromPlayRecords(_ index: Int) {
        guard playedTracks.indices.contains(index) else { return }
        playedTracks.remove(at: index)
    }

    /// 清空播放紀錄
    func clearPlayRecords() {
        UserDefaults.playedTracks.removeAll()
    }

    // MARK: Private

    // 用來來逐漸增加播放速度的計時器(快轉/倒帶)
    private var speedIncreasingTimer: Timer?

    // 用來控制系統音量（只使用它裡面的 slider ）
    private let mpVolumeView: MPVolumeView = .init()
    private let audioSession = AVAudioSession.sharedInstance()
    private var volumeObserver: NSKeyValueObservation?
    // 控制循環播放
    private var looper: AVPlayerLooper?
    // 觀察播放進度
    private var timeObserverToken: Any?

    private let currentTrackIndexSubject = CurrentValueSubject<Int, Never>(0)
    private let timeSubject = CurrentValueSubject<Double?, Never>(nil)
    private let volumeSubject = CurrentValueSubject<Float, Never>(0)
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isShuffleModeSubject = CurrentValueSubject<Bool, Never>(UserDefaults.isShuffleMode)

    // 待播清單索引陣列
    private var displayIndices: [Int] {
        get { isShuffleMode ? shuffledIndices : serialIndices }
        set {
            if isShuffleMode {
                shuffledIndices = newValue
            } else {
                serialIndices = newValue
            }
        }
    }

    // 待播清單索引陣列
    private var serialIndices: [Int] {
        get { UserDefaults.displayIndices }
        set { UserDefaults.displayIndices = newValue }
    }

    // 亂序的待播清單索引陣列
    private var shuffledIndices: [Int] {
        get { UserDefaults.shuffledDisplayIndices }
        set { UserDefaults.shuffledDisplayIndices = newValue }
    }

    private func updateDisplayIndices() {
        let nextIndex = currentTrackIndex + 1
        if !playlist.isValidIndex(nextIndex) {
            // 如果沒有待播放的顯示空陣列
            displayIndices = []
        } else {
            // 取得當前音樂之後待播放的所有項目
            displayIndices = Array(nextIndex ..< playlist.count)
        }
    }

    /// 更新播放時使用的 AVPlayerItem
    private func resetPlayerItem(track: Track?) {
        guard let track, let audioURL = URL(string: track.previewUrl) else {
            Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
            return
        }
        // 移除時間觀察
        removeTimeObserver()

        // 回到歌曲開頭
        seek(to: 0)
        let playerItem = AVPlayerItem(url: audioURL)
        player.replaceCurrentItem(with: playerItem)

        // 因為切換過 playerItem，要重設 isPlaying 狀態
        isPlaying = isPlaying
        // 新增時間觀察
        addTimeObserver()
    }

    // MARK: Setup

    private func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //  設定背景&鎖定播放
        setupRemoteTransportControls()
    }

    private func setupObservers() {
        // 每首歌曲播放完畢時更新索引
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            self?.playerItemDidPlayToEndTime()
        }

        // 監聽系統音量變化
        // 參考 https://stackoverflow.com/questions/68249775/system-volume-change-observer-not-working-on-ios-15
        try? audioSession.setActive(true)
        volumeObserver = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let newVolume = change.newValue else { return }
            self?.volumeChanged(newVolume)
        }
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

    @discardableResult
    private func prepareToPlay(at index: Int) -> Bool {
        guard !playlist.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return false
        }
        guard playlist.isValidIndex(index) else {
            Utils.toast(MusicPlayerError.invalidIndex.unwrapDescription)
            return false
        }

        resetPlayerItem(track: playlist[index])
        currentTrackIndex = index
        updateDisplayIndices()
        return true
    }

    private func volumeChanged(_ newVolume: Float) {
        volume = newVolume
    }

    // 音樂播放超過5秒才加入播放紀錄
    private func addPlayRecordIfNeeded() {
        if let currentTrack, let currentPlaybackTime, currentPlaybackTime >= 5 {
            playedTracks.append(currentTrack)
        }
    }
}

// MARK: MusicPlayerControl

extension MusicPlayer {
    ///  播放當前曲目(從頭開始播放)
    func play() {
        prepareToPlay(at: currentTrackIndex)
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
        prepareToPlay(at: 0)
        isPlaying = false
        player.seek(to: CMTime.zero)
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
    /// 歌曲播放完畢準備進入下一首(自動接續)
    private func playerItemDidPlayToEndTime() {
        var nextIndex: Int
        switch repeatMode {
        // 循環播放單曲
        case .one:
            nextIndex = currentTrackIndex
        // 循環播放全部/不循環播放
        case .all, .none:
            nextIndex = currentTrackIndex + 1
        }
        if nextIndex >= playlist.count {
            // 超過索引就從第一首歌重新播放
            nextIndex = 0
            // 如果播放到最後一首歌，且選擇不循環播放，就停止播放
            if repeatMode == .none {
                pause()
            }
        }
        addPlayRecordIfNeeded()
        prepareToPlay(at: nextIndex)
    }

    /// 播放下一首(手動觸發)
    @discardableResult
    func nextTrack() -> Bool {
        var nextIndex = currentTrackIndex + 1
        // 超過索引就從第一首歌重新播放
        if !displayIndices.contains(nextIndex) {
            nextIndex = 0
        }
//        if !playlist.isValidIndex(nextIndex) {
//            nextIndex = 0
//        }
        addPlayRecordIfNeeded()
        return prepareToPlay(at: nextIndex)
    }

    /// 播放上一首
    @discardableResult
    func previousTrack() -> Bool {
        var previousIndex = currentTrackIndex - 1
        // 避免超出索引
        previousIndex = max(0, previousIndex)
        return prepareToPlay(at: previousIndex)
    }

    /// 隨機排序待播清單
    func toggleShuffleMode() {
        if isShuffleMode {
            displayIndices = playlist.indices.shuffled()
        } else {
            displayIndices = serialIndices
        }
        isShuffleModeSubject.send(isShuffleMode)
    }
}

// MARK: MusicPlayerSpeedControl

extension MusicPlayer {
    // 播放速率上限
    var maxPlaybackRate: Float {
        3.0
    }

    /// 快轉
    func fastForward() {
        // 越來越快直到上限
        speedIncreasingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            let newRate = min(self.playbackRate + 0.1, self.maxPlaybackRate)
            self.playbackRate = newRate
        }
    }

    /// 倒帶
    func rewind() {
        speedIncreasingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            let newRate = min(abs(self.playbackRate) + 0.1, self.maxPlaybackRate)
            self.playbackRate = -newRate // 倒轉要用負的
        }
    }

    /// 回復正常速度
    func resetPlaybackRate() {
        speedIncreasingTimer?.invalidate()
        speedIncreasingTimer = nil
        playbackRate = 1
    }
}

// MARK: MPVolumeView

extension MPVolumeView {
    /// 取得 MPVolumeView 的 slider 以操控系統音量
    var volumeSlider: UISlider? {
        subviews.first { $0 is UISlider } as? UISlider
    }
}

// player.addBoundaryTimeObserver  傳入指定時間(陣列)要進行的行為
