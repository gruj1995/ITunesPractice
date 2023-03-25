//
//  MusicPlayer.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import AVFoundation
import Foundation

// MARK: - MusicPlayer

class MusicPlayer: MusicPlayerProtocol {
    // MARK: Internal

    static let shared = MusicPlayer()

    var isPlaying: Bool = false

    /// 播放清單
    var tracks: [Track] = []

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
        default:
            nextIndex = (currentTrackIndex ?? -1) + 1
            if !tracks.isValidIndex(nextIndex) {
                stop()
                return
            }
        }

        try play(at: nextIndex)
    }

    // MARK: Private

    private var player: AVPlayer?
    // 目前選中的歌曲索引
    private var currentTrackIndex: Int?
    // 是否隨機播放
    private var isShuffleMode: Bool = false
    // 重複的模式
    private var repeatMode: RepeatMode = .none
    // 播放速率
    private var playbackRate: Float = 1.0
    // 播放速率上限
    private let maxPlaybackRate: Float = 2.0
    // 播放速率下限
    private let minPlaybackRate: Float = 0.5

    /// 播放指定索引的歌曲
    private func play(at index: Int) throws {
        guard !tracks.isEmpty else {
            throw MusicPlayerError.emptyPlaylist
        }
        guard tracks.isValidIndex(index) else {
            throw MusicPlayerError.invalidIndex
        }

        let track = tracks[index]
        guard let audioURL = URL(string: track.previewUrl) else {
            throw MusicPlayerError.invalidTrack
        }

        let playerItem = AVPlayerItem(url: audioURL)

        if let player = player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }

        player?.play()
        isPlaying = true
        currentTrackIndex = index
    }

    /// 設置播放速率
    private func setPlaybackRate(_ rate: Float) {
        if isPlaying {
            // 屬性需要在主線程上訪問 rate
            DispatchQueue.main.async { [weak self] in
                self?.player?.rate = rate
            }
        }
        playbackRate = rate
    }
}

// MARK: MusicPlayerControl

extension MusicPlayer {
    ///  播放當前曲目(從頭開始播放)
    func play() throws {
        guard let index = currentTrackIndex else {
            throw MusicPlayerError.emptyPlaylist
        }

        try play(at: index)
    }

    /// 暫停
    func pause() {
        player?.pause()
        isPlaying = false
    }

    /// 繼續播放
    func resume() {
        player?.play()
        isPlaying = true
    }

    /// 停止播放(清除目前播放的)
    func stop() {
        player?.pause()
        isPlaying = false
        player?.replaceCurrentItem(with: nil)
        currentTrackIndex = nil
    }

//    /// 停止播放(暫停並將時間設到歌曲開始)
//    func stop() {
//        player?.pause()
//        isPlaying = false
//        player?.seek(to: CMTime.zero)
//    }
}

// MARK: MusicPlayerPlaylistControl

extension MusicPlayer {
    /// 播放指定曲目
    func play(track: Track) throws {
        guard let index = tracks.firstIndex(of: track) else {
            throw MusicPlayerError.invalidTrack
        }
        try play(at: index)
    }

    /// 播放清單內的下一首
    func nextTrack() throws {
        guard let index = currentTrackIndex else {
            throw MusicPlayerError.emptyPlaylist
        }
        let nextIndex = isShuffleMode ? tracks.randomIndexExcluding(index) : index + 1
        try play(at: nextIndex)
    }

    /// 播放清單內的上一首
    func previousTrack() throws {
        guard let index = currentTrackIndex else {
            throw MusicPlayerError.emptyPlaylist
        }
        let previousIndex = isShuffleMode ? tracks.randomIndexExcluding(index) : index - 1
        try play(at: previousIndex)
    }
}

// MARK: MusicPlayerSpeedControl

extension MusicPlayer {
    /// 快轉
    func fastForward() {
        // 越來越快直到上限
        let newFastForwardRate = min(playbackRate + 0.1, maxPlaybackRate)
        setPlaybackRate(newFastForwardRate)
    }

    /// 倒帶
    func rewind() {
        // 越來越慢直到下限
        let newRewindRate = max(playbackRate - 0.1, minPlaybackRate)
        setPlaybackRate(newRewindRate)
    }
}

// MARK: MusicPlayerShuffleControl

extension MusicPlayer {
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
