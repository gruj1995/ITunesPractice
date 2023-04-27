//
//  PlayListViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import ColorKit
import Combine
import Kingfisher
import UIKit

// MARK: - PlaylistViewModel

class PlaylistViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var selectedIndexPath: IndexPath?

    private(set) var currentTrack: Track? {
        get { musicPlayer.currentTrack }
        set {
            if let index = playlist.firstIndex(where: { $0 == newValue }) {
                musicPlayer.currentTrackIndex = index
            }
        }
    }

    var totalCount: Int {
        playlist.count + playedTracks.count
    }

    var numberOfSections: Int {
        playedTracks.isEmpty ? 1 : 2
    }

    var colors: [UIColor] {
        get { colorsSubject.value }
        set { colorsSubject.value = newValue }
    }

    var headerButtonBgColor: UIColor? {
        if colors.count >= 3 {
            return colors[1]
        }
        return nil
    }

    var isShuffleMode: Bool {
        get { musicPlayer.isShuffleMode }
        set { musicPlayer.isShuffleMode = newValue }
    }

    var isInfinityMode: Bool {
        get { musicPlayer.isInfinityMode }
        set { musicPlayer.isInfinityMode = newValue }
    }

    var repeatMode: RepeatMode {
        get { musicPlayer.repeatMode }
        set { musicPlayer.repeatMode = newValue }
    }

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        musicPlayer.currentTrackIndexPublisher
    }

    var colorsPublisher: AnyPublisher<[UIColor], Never> {
        colorsSubject.eraseToAnyPublisher()
    }

    func numberOfRows(in section: Int) -> Int {
        isPlayedTracksSection(section) ? playedTracks.count : playlist.count
    }

    func track(forCellAt indexPath: IndexPath) -> Track? {
        let tracks = isPlayedTracksSection(indexPath.section) ? playedTracks : playlist
        guard tracks.indices.contains(indexPath.row) else { return nil }
        return tracks[indexPath.row]
    }

    func setCurrentTrack(forCellAt indexPath: IndexPath) {
        let tracks = isPlayedTracksSection(indexPath.section) ? playedTracks : playlist
        guard tracks.indices.contains(indexPath.row) else { return }
        currentTrack = tracks[indexPath.row]
    }

    // 是否為播放紀錄 section
    func isPlayedTracksSection(_ section: Int) -> Bool {
        !playedTracks.isEmpty && (section == 0)
    }

    // 是否為待播清單第一項
    func isFirstItemInPlaylist(_ indexPath: IndexPath) -> Bool {
        !isPlayedTracksSection(indexPath.section) && indexPath.row == 0
    }

    // 清除播放紀錄
    func clearPlayRecords() {
        UserDefaults.playedTracks.removeAll()
    }

    func removeTrack(forCellAt indexPath: IndexPath) {
        if isPlayedTracksSection(indexPath.section) {
            musicPlayer.removeFromPlayRecords(indexPath.row)
        } else {
            musicPlayer.removeFromPlaylist(indexPath.row)
        }
    }

    func play() {
        musicPlayer.play()
    }

    func changeImage() {
        let url = currentTrack?.artworkUrl100
        downloadImage(with: url)
    }

    // MARK: Private

    // TODO: 為什麼PassthroughSubject只觸發一次？
    private let colorsSubject = CurrentValueSubject<[UIColor], Never>(DefaultTrack.gradientColors)
    private var cancellables: Set<AnyCancellable> = .init()
    private let musicPlayer: MusicPlayer = .shared

    // 待播清單
    private var playlist: [Track] {
        musicPlayer.playlist
//        var allTracks = musicPlayer.playlist
//        // 不顯示正在播放的
//        return Array(allTracks.dropFirst())
    }

    // 播放紀錄
    private var playedTracks: [Track] {
        musicPlayer.playedTracks
    }

    /// 異步下載圖檔
    private func downloadImage(with urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            colors = DefaultTrack.gradientColors
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let value):
//                Logger.log("Image: \(value.image). Got from: \(value.cacheType)")
                // TODO: 目前用同步方式提取漸層色會導致進頁面卡頓，但沒有先等的話頁面會沒有背景色，之後考慮使用catche暫存顏色解決此問題
                self?.generateColors(by: value.image)
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }

    /// 從圖檔提取出主要顏色，再依淺到深順序，取最深的3個顏色回傳
    private func generateColors(by image: UIImage) {
        do {
            // - quality: 決定取色的品質
            // - algorithm: 使用 kMensCluster 算法或是迭代像素算法
            let allColors = try image.dominantColors(with: .fair, algorithm: .iterative)
            let sortedColors = allColors.sortedByGrayValue(isDesc: false)
            colors = Array(sortedColors.suffix(3))
        } catch {
            Logger.log(error)
        }
    }
}
