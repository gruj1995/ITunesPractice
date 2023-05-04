//
//  Playlist2.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/1.
//

import Foundation

class Playlist2 {
    // 播放清單
    var mainPlaylist: [Track] {
        get { UserDefaults.mainPlaylist }
        set { UserDefaults.mainPlaylist = newValue }
    }

    // 展示用的播放清單
    var pendingPlaylist: [Track] {
        displayIndices.map { mainPlaylist[$0] }
    }

    // 播放紀錄
    var playedTracks: [Track] {
        get { UserDefaults.playedTracks }
        set { UserDefaults.playedTracks = newValue }
    }

    var currentTrack: Track? {
        guard mainPlaylist.indices.contains(currentTrackIndex) else { return nil }
        return mainPlaylist[currentTrackIndex]
    }

    var currentTrackIndex: Int {
        get { UserDefaults.currentTrackIndex }
        set { UserDefaults.currentTrackIndex = newValue }
    }

    // 待播清單索引陣列
    private var displayIndices: [Int] {
        isShuffleMode ? shuffledIndices : serialIndices
    }

    // 待播清單索引陣列
    private var serialIndices: [Int] {
        get { UserDefaults.orderedIndices }
        set { UserDefaults.orderedIndices = newValue }
    }

    // 亂序的待播清單索引陣列
    private var shuffledIndices: [Int] {
        get { UserDefaults.shuffledIndices }
        set { UserDefaults.shuffledIndices = newValue }
    }

    // MARK: Shuffle

    var shuffleModeFirstTrackIndex: Int = 0

    var entireShuffledIndices: [Int] = []

    var currentShuffleTrackIndex: Int {
        get { UserDefaults.currentShuffleTrackIndex }
        set { UserDefaults.currentShuffleTrackIndex = newValue }
    }

    // 是否隨機播放
    var isShuffleMode: Bool {
        get { UserDefaults.isShuffleMode }
        set {
            UserDefaults.isShuffleMode = newValue
            toggleShuffleMode()
        }
    }

    // MARK: 共用

    func nextTrack() {
        addPlayRecordIfNeeded()

        if isShuffleMode {
            nextTrackInShuffledPendingList()
        } else {
            nextTrackInPendingList()
        }
    }

    private func nextTrackInShuffledPendingList() {
        // 超過索引就從第一首歌重新播放
        let nextIndex = currentShuffleTrackIndex + 1
        let nextIndexInMain = nextIndex >= shuffledIndices.count ? shuffleModeFirstTrackIndex : nextIndex
        prepareToPlay(at: nextIndexInMain)
    }

    private func nextTrackInPendingList() {
        // 超過索引就從第一首歌重新播放
        let nextIndexInMain = (currentTrackIndex + 1) % mainPlaylist.count
        prepareToPlay(at: nextIndexInMain)
    }

    func previousTrack() {
        if isShuffleMode {
            previousTrackInShuffledPendingList()
        } else {
            previousTrackInPendingList()
        }
    }

    private func previousTrackInShuffledPendingList() {
        // 超過索引就從第一首歌重新播放
        let previousIndex = currentShuffleTrackIndex - 1
        let previousIndexInMain = previousIndex < 0 ? shuffleModeFirstTrackIndex : previousIndex
        prepareToPlay(at: previousIndexInMain)
    }

    private func previousTrackInPendingList() {
        // 避免超出索引
        let previousIndexInMain = max(0, currentTrackIndex - 1)
        prepareToPlay(at: previousIndexInMain)
    }

    @discardableResult
    private func prepareToPlay(at index: Int) -> Bool {
        guard !mainPlaylist.isEmpty else {
            Utils.toast(MusicPlayerError.emptyPlaylist.unwrapDescription)
            return false
        }
        guard mainPlaylist.isValidIndex(index) else {
            Utils.toast(MusicPlayerError.invalidIndex.unwrapDescription)
            return false
        }

        let track = mainPlaylist[index]
//        resetPlayerItem(track: playlist[index])
        currentTrackIndex = index
//        updateDisplayIndices()
        return true
    }

    // 將正在播放的音樂加入播放紀錄
    private func addPlayRecordIfNeeded() {
        if let currentTrack {
            playedTracks.append(currentTrack)
        }
    }

    /// 加到待播清單首項
    func insertToFirst(track: Track) {
        let newIndex = serialIndices.first ?? 0
        mainPlaylist.insert(track, at: newIndex)
        serialIndices.insert(newIndex, at: 0)
        shuffledIndices.insert(newIndex, at: 0)
    }

    /// 加到待播清單末項
    func addToLast(track: Track) {
        mainPlaylist.append(track)
        serialIndices.append(serialIndices.count)
        shuffledIndices.append(shuffledIndices.count)
    }

    /// 刪除指定的待播清單項目
    func removeTrackFromDisplayPlaylist(at index: Int) {
        let trackIndex = displayIndices[index]
        guard mainPlaylist.indices.contains(trackIndex) else { return }
        mainPlaylist.remove(at: trackIndex)

        if isShuffleMode {
            shuffledIndices.remove(at: index)
        } else {
            serialIndices.remove(at: index)
        }
//        updateDisplayIndices()
    }

    func toggleShuffleMode() {
        if isShuffleMode {
            shuffleModeFirstTrackIndex = currentTrackIndex
            currentShuffleTrackIndex = 0
            entireShuffledIndices = mainPlaylist.filter { $0 != currentTrack }.indices.shuffled()
            shuffledIndices = entireShuffledIndices
        } else {
            shuffleModeFirstTrackIndex = 0
            currentShuffleTrackIndex = 0
            entireShuffledIndices = []
            shuffledIndices = []
        }
    }
}
