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

    // MARK: Shuffle

    // 播放清單
    var mainTracks: [Track] {
        get { UserDefaults.mainTracks }
        set { UserDefaults.mainTracks = newValue }
    }

    // 展示用的播放清單
    var pendingPlaylist: [Track] {
        // 從主播放列表中選擇所有需要播放的歌曲，並排除已經播放的第一首歌曲
        if displayIndices.count <= 1 {
            return []
        } else {
            return Array(displayIndices.dropFirst().map { mainTracks[$0] })
        }
    }

    // 播放紀錄
    var playedTracks: [Track] {
        get { UserDefaults.playedTracks }
        set { UserDefaults.playedTracks = newValue }
    }

    var currentTrack: Track? {
        let shuffledIndex = entireShuffledIndices.isEmpty ? 0 : entireShuffledIndices[currentShuffleTrackIndex]
        let index = isShuffleMode ? shuffledIndex : currentTrackIndex
        guard mainTracks.indices.contains(index) else { return nil }
        return mainTracks[index]
    }

    var currentTrackIndex: Int {
        get { UserDefaults.currentTrackIndex }
        set { UserDefaults.currentTrackIndex = newValue
            currentTrackIndexSubject.value = newValue
            // 設定背景當前播放資訊
            setupNowPlaying()
        }
    }

    var currentShuffleTrackIndex: Int {
        get { UserDefaults.currentShuffleTrackIndex }
        set { UserDefaults.currentShuffleTrackIndex = newValue
            currentTrackIndexSubject.value = newValue
            // 設定背景當前播放資訊
            setupNowPlaying()
        }
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

    // MARK: Player

    /// 在 AppDelegate 呼叫，讓 MusicPlayer 在開啟app時就建立
    func configure() {}

    /// 選中的待播清單項目
    func setCurrentTrackIndex(to index: Int) {
        guard displayIndices.count > 1 else { return }
        let pendingListIndex = index + 1 // 因為第一項是正在播放的，所以這邊要加1
        let targetIndex = displayIndices[pendingListIndex]
        guard mainTracks.indices.contains(targetIndex) else { return }
        currentTrackIndex = targetIndex
        if isShuffleMode {
            currentShuffleTrackIndex += pendingListIndex
            // 更新顯示的隨機待播清單索引
            shuffledIndices = Array(entireShuffledIndices.dropFirst(currentShuffleTrackIndex))
        }
    }

    /// 刪除指定的待播清單項目
    func removeTrackFromDisplayPlaylist(at index: Int) {
        guard displayIndices.count > 1 else { return }
        let targetIndex = displayIndices[index]
        guard mainTracks.indices.contains(targetIndex) else { return }
        mainTracks.remove(at: targetIndex)

        if isShuffleMode {
            // 更新完整的隨機待播清單索引(因為主音樂清單索引有變動)
            entireShuffledIndices.removeAll { $0 == targetIndex }
            entireShuffledIndices = entireShuffledIndices.map {
                $0 > targetIndex ? ($0 - 1) : $0
            }
            // 更新顯示的隨機待播清單索引
            shuffledIndices = Array(entireShuffledIndices.dropFirst(currentShuffleTrackIndex))
        } else {
            updateOrderedIndices()
        }
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

    /// 更新播放清單並播放指定歌曲
    func refreshPlaylistAndPlaySong(_ playlist: Playlist, at index: Int) {
        mainTracks = playlist.tracks
        currentTrackIndex = index
        updateOrderedIndices()
        currentShuffleTrackIndex = 0
        entireShuffledIndices = []
        shuffledIndices = []
        play()
    }

    func nextTrack() {
        if isShuffleMode {
            nextTrackInShuffledPendingList()
        } else {
            nextTrackInPendingList()
        }
    }

    func previousTrack() {
        // 點擊上一曲時，音樂播放大於4秒回到歌曲開頭
        if let currentPlaybackTime, currentPlaybackTime >= 4 {
            seek(to: 0)
            return
        }

        if isShuffleMode {
            previousTrackInShuffledPendingList()
        } else {
            previousTrackInPendingList()
        }
    }

    /// 取代正播放的音樂
    func replaceCurrentTrack(_ track: Track) {
        addPlayRecordIfNeeded()

        if isShuffleMode {
            if shuffledIndices.isEmpty {
                addTrack(track)
                entireShuffledIndices.append(0)
                updateShuffledIndices()
            } else {
                // 加到正在播放的音樂之後
                // 主音樂清單索引往後一格並插入新歌
                currentTrackIndex += 1
                addTrack(track, at: currentTrackIndex)
                // 更新隨機待播清單的索引(因為主音樂清單索引有變動)
                entireShuffledIndices = entireShuffledIndices.map {
                    $0 >= currentTrackIndex ? ($0 + 1) : $0
                }
                currentShuffleTrackIndex += 1
                entireShuffledIndices.insert(currentTrackIndex, at: currentShuffleTrackIndex)
                // 更新顯示的隨機待播清單索引
                shuffledIndices = Array(entireShuffledIndices.dropFirst(currentShuffleTrackIndex))
            }
        } else {
            if orderedIndices.isEmpty {
                addTrack(track)
                orderedIndices.append(0)
            } else {
                currentTrackIndex += 1
                addTrack(track, at: currentTrackIndex)
                updateOrderedIndices()
            }
        }
    }

    /// 加到待播清單首項
    func insertTrackToPlaylist(_ track: Track) {
        if isShuffleMode {
            if shuffledIndices.isEmpty {
                addTrack(track)
                entireShuffledIndices.append(0)
                updateShuffledIndices()
            } else {
                let pendingListFirstIndex = currentTrackIndex + 1
                addTrack(track, at: pendingListFirstIndex)
                // 更新隨機待播清單的索引(因為主音樂清單索引有變動)
                entireShuffledIndices = entireShuffledIndices.map {
                    $0 >= pendingListFirstIndex ? ($0 + 1) : $0
                }
                entireShuffledIndices.insert(pendingListFirstIndex, at: currentShuffleTrackIndex + 1)
                // 更新顯示的隨機待播清單索引
                shuffledIndices = Array(entireShuffledIndices.dropFirst(currentShuffleTrackIndex))
            }
        } else {
            if orderedIndices.isEmpty {
                addTrack(track)
                orderedIndices.append(0)
            } else {
                let pendingListFirstIndex = currentTrackIndex + 1
                addTrack(track, at: pendingListFirstIndex)
                updateOrderedIndices()
            }
        }
    }

    /// 加到待播清單末項
    func addTrackToPlaylist(_ track: Track) {
        if isShuffleMode {
            addTrack(track)
            entireShuffledIndices.append(entireShuffledIndices.count)
            // 更新顯示的隨機待播清單索引
            shuffledIndices = Array(entireShuffledIndices.dropFirst(currentShuffleTrackIndex))
        } else {
            addTrack(track)
            orderedIndices.append(mainTracks.count - 1)
        }
    }

    func toggleShuffleMode() {
        if isShuffleMode {
            // 把正在播放的放到最前面
            if !mainTracks.isEmpty {
                entireShuffledIndices = mainTracks.indices.filter { $0 != currentTrackIndex }.shuffled()
                entireShuffledIndices.insert(currentTrackIndex, at: 0)
            }
            shuffledIndices = entireShuffledIndices
            currentShuffleTrackIndex = 0
        } else {
            entireShuffledIndices = []
            shuffledIndices = []
            currentShuffleTrackIndex = 0
            updateOrderedIndices()
        }
        isShuffleModeSubject.send(isShuffleMode)
    }

    // MARK: Private

    // 用來控制系統音量（只使用它裡面的 slider ）
    private let mpVolumeView: MPVolumeView = .init()
    private let audioSession = AVAudioSession.sharedInstance()
    private var volumeObserver: NSKeyValueObservation?

    // 控制循環播放
    private var looper: AVPlayerLooper?

    // 觀察播放進度
    private var timeObserverToken: Any?

    // 用來來逐漸增加播放速度的計時器(快轉/倒帶)
    private var speedIncreasingTimer: Timer?

    private let currentTrackIndexSubject = CurrentValueSubject<Int, Never>(0)
    private let timeSubject = CurrentValueSubject<Double?, Never>(nil)
    private let volumeSubject = CurrentValueSubject<Float, Never>(0)
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isShuffleModeSubject = CurrentValueSubject<Bool, Never>(UserDefaults.isShuffleMode)

    // 待播清單索引陣列
    private var displayIndices: [Int] {
        return isShuffleMode ? shuffledIndices : orderedIndices
    }

    // 待播清單索引陣列
    private var orderedIndices: [Int] {
        get { UserDefaults.orderedIndices }
        set { UserDefaults.orderedIndices = newValue }
    }

    // 亂序的待播清單索引陣列
    private var shuffledIndices: [Int] {
        get { UserDefaults.shuffledIndices }
        set { UserDefaults.shuffledIndices = newValue }
    }

    private var entireShuffledIndices: [Int] {
        get { UserDefaults.entireShuffledIndices }
        set { UserDefaults.entireShuffledIndices = newValue }
    }

    private func addTrack(_ track: Track, at index: Int? = nil) {
        if let index {
            mainTracks.insert(track.autoIncrementID(), at: index)
        } else {
            mainTracks.append(track.autoIncrementID())
        }
    }

    // MARK: Setup

    private func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // 設定背景&鎖定播放
        setupRemoteTransportControls()
    }

    private func setupObservers() {
        // 每首歌曲播放完畢時更新索引
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

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
        guard !mainTracks.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return false
        }
        guard mainTracks.isValidIndex(index) else {
            Utils.toast(MusicPlayerError.invalidIndex.unwrapDescription)
            return false
        }

        resetPlayerItem(track: mainTracks[index])
        currentTrackIndex = index
        updateOrderedIndices()
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

    private func nextTrackInPendingList() {
        addPlayRecordIfNeeded()
        var nextIndex = 0
        if !mainTracks.isEmpty {
            // 超過索引就從第一首歌重新播放
            nextIndex = (currentTrackIndex + 1) % mainTracks.count
        }
        prepareToPlay(at: nextIndex)
    }

    private func nextTrackInShuffledPendingList() {
        guard !entireShuffledIndices.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return
        }
        addPlayRecordIfNeeded()

        let nextIndex = currentShuffleTrackIndex + 1
        // 超過索引就從第一首歌重新播放
        if nextIndex >= entireShuffledIndices.count {
            currentShuffleTrackIndex = 0
            updateShuffledIndices()
        } else {
            shuffledIndices.removeFirst()
            currentShuffleTrackIndex = nextIndex
        }

        let nextIndexInMain = entireShuffledIndices[currentShuffleTrackIndex]
        prepareToPlay(at: nextIndexInMain)
    }

    private func previousTrackInShuffledPendingList() {
        guard !entireShuffledIndices.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return
        }

        let previousIndex = currentShuffleTrackIndex - 1
        // 到第一首不能再往前
        currentShuffleTrackIndex = max(0, previousIndex)
        let previousIndexInMain = entireShuffledIndices[currentShuffleTrackIndex]
        if previousIndex >= 0 {
            shuffledIndices.insert(previousIndexInMain, at: 0)
        }
        prepareToPlay(at: previousIndexInMain)
    }

    private func previousTrackInPendingList() {
        // 到第一首不能再往前
        let previousIndexInMain = max(0, currentTrackIndex - 1)
        prepareToPlay(at: previousIndexInMain)
    }

    private func updateShuffledIndices() {
        shuffledIndices = entireShuffledIndices
    }

    private func updateOrderedIndices() {
        if !mainTracks.isValidIndex(currentTrackIndex) {
            orderedIndices = []
        } else {
            // 重設待播清單
            orderedIndices = Array(currentTrackIndex ..< mainTracks.count)
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
}

// MARK: MusicPlayerControl

extension MusicPlayer {
    ///  播放當前曲目(從頭開始播放)
    func play() {
        prepareToPlay(at: isShuffleMode ? currentShuffleTrackIndex : currentTrackIndex)
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
//        prepareToPlay(at: 0)
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
    /// 歌曲播放完畢準備進入下一首(自動接續)
    @objc
    private func playerItemDidPlayToEndTime(_ notification: Notification) {
        // 避免誤收到其他 player 的通知
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == player.currentItem
        else {
            return
        }

        switch repeatMode {
        // 循環播放單曲
        case .one:
            addPlayRecordIfNeeded()
            play()

        // 循環播放全部
        case .all:
            nextTrack()

        // 不循環播放
        case .none:
            nextTrack()
            // 播放到最後一首歌就停止播放
            if isLastInPendingList {
                pause()
            }
        }
    }

    private var isLastInPendingList: Bool {
        isShuffleMode ? (currentShuffleTrackIndex == entireShuffledIndices.count - 1) : (currentTrackIndex == mainTracks.count - 1)
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
