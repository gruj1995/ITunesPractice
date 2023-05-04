//
//  MusicPlayer+Remote.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/13.
//

import Foundation
import MediaPlayer
import Combine

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
            previousTrack()
            return .success
        }

        // 下一曲
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            nextTrack()
            return .success
        }

        // 控制播放進度(調整遠程控制中心的進度條更新app內的進度條)
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            seek(to: event.positionTime) { _ in
                self.nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentPlaybackTime
            }
            return .success
        }

        // TODO: 待確認是否有更好的更新方式。因為遠程控制中心本來好像會自動更新進度，只是在暫停或播放後進度沒有變動，所以這邊才用以下方式通知更新。
        // 更新遠程控制中心的播放進度
        playbackTimePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentPlaybackTime
                self.nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = self.currentTimeFloatValue
            }.store(in: &cancellables)
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
        // 當前播放進度（單位：秒）
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlaybackTime
        // 當前曲目總長度 (這邊使用 currentPlaybackDuration 會無法拖動)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
        // 當前播放的速度
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        // nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = currentTimeFloatValue

        currentTrack?.getCoverImage(size: .square400) { [weak self] result in
            switch result {
            case .success(let image):
                guard let image else {
                    self?.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
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
            self?.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
}
