//
//  MusicPlayer+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/13.
//

import Foundation
import MediaPlayer

// 官方文件： https://developer.apple.com/documentation/avfoundation/media_playback/creating_a_basic_video_player_ios_and_tvos/controlling_background_audio

extension MusicPlayer {
    // 管理遠程控制中心的框架，提供了一個集中的地方來處理耳機上的按鈕、鎖屏界面和控制中心中的媒體控制
    var commandCenter: MPRemoteCommandCenter {
        MPRemoteCommandCenter.shared()
    }

    var nowPlayingInfoCenter: MPNowPlayingInfoCenter {
        MPNowPlayingInfoCenter.default()
    }

    //  設定遠程控制中心(背景&鎖定時出現)的相關事件
    func setupRemoteTransportControls() {
        // 切換播放/暫停
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
            isPlaying.toggle()
            return .success
        }

        // 上一曲
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            if previousTrack() {
                return .success
            }
            return .commandFailed
        }

        // 下一曲
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            if nextTrack() {
                return .success
            }
            return .commandFailed
        }

        // 控制播放進度
        let changePlaybackPositionCommand = commandCenter.changePlaybackPositionCommand
//        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            // 需要使用带回调的SeekTime 回调重新设置进度 否则播放进度条会停止
            seek(to: event.positionTime) { _ in
                // Q:拖动介绍后进度条不动了
                // A:恢复时重新配置MPNowPlayingInfoPropertyElapsedPlaybackTime
                var dic = self.nowPlayingInfoCenter.nowPlayingInfo
                dic?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: CMTimeGetSeconds(self.player.currentTime()))
                self.nowPlayingInfoCenter.nowPlayingInfo = dic
            }
            return .success
        }
    }

    //  設定背景播放的歌曲資訊
    func setupNowPlaying() {
        let trackName: String = currentTrack?.trackName ?? DefaultTrack.trackName
        let collectionName: String = currentTrack?.collectionName ?? ""

        var nowPlayingInfo = [String: Any]()
        // 當前曲目名稱
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        // 當前專輯名稱
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = collectionName
        // 當前播放進度
        // player.currentItem?.currentTime().seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlaybackTime

//        let progress = currentTimeFloatValue / totalDurationFloatValue
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = NSNumber(value: progress)
        // 當前曲目總長度 (這邊使用 currentPlaybackDuration 會無法拖動)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
        // 當前播放的速度
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate

        currentTrack?.getCoverImage(size: .square400) { result in
            switch result {
            case .success(let image):
                guard let image else {
                    self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
                    return
                }
                // 專輯封面圖片
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { _ in
                        image
                    }
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }

            // Set the metadata
            self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
}
