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

    var currentTrack: Track? {
        get { musicPlayer.currentTrack }
        set {
            if let index = tracks.firstIndex(where: { $0 == newValue }) {
                musicPlayer.currentTrackIndex = index
            }
        }
    }

    var tracks: [Track] {
        musicPlayer.tracks
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

    var totalCount: Int {
        tracks.count
    }

    var numberOfSections: Int {
        1
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
        totalCount
    }

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

    func play() {
        musicPlayer.play()
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentTrack = tracks[index]
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