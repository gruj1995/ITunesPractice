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

    init() {
        // 監聽歌曲選中事件
//        selectTrackPublisher
//            .sink { [weak self] track in
//                self?.musicPlayer.selectTrack(track)
//            }
//            .store(in: &cancellables)
//        setSelectedTrack(player.)
    }

    // MARK: Internal

    var selectedIndexPath: IndexPath?

    var currentTrack: Track? {
        get {
            musicPlayer.currentTrack
        }
        set {
            if let index = tracks.firstIndex(where: { $0 == newValue }) {
                musicPlayer.currentTrackIndex = index
                musicPlayer.play()
                changeImage()
            }
        }
    }

    var tracks: [Track] {
        musicPlayer.tracks
    }

    var totalCount: Int {
        tracks.count
    }

    var numberOfSections: Int {
        1
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
        guard index < tracks.count else { return nil }
        return tracks[index]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard index < tracks.count else { return }
        currentTrack = tracks[index]
    }

    func toggleShuffleMode() {
        musicPlayer.toggleShuffleMode()
    }

    // MARK: Private

    // TODO: 為什麼PassthroughSubject只觸發一次？
    private let colorsSubject = CurrentValueSubject<[UIColor], Never>(DefaultTrack.gradientColors)

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Inputs

    private let musicPlayer: MusicPlayer = .shared

    private func changeImage() {
        let url = currentTrack?.artworkUrl100
        downloadImage(with: url)
    }

    /// 異步下載圖檔
    private func downloadImage(with urlString: String?) {
        guard let urlString = urlString else {
            colorsSubject.send(DefaultTrack.gradientColors)
            return
        }

        guard let url = URL(string: urlString) else {
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                Logger.log("Image: \(value.image). Got from: \(value.cacheType)")
                // TODO: 這邊同步會導致進頁面卡頓，但沒有先做完的話頁面會沒有背景色，看如何取捨
                self.generateColors(by: value.image)
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
            let allColors = try image.dominantColors(with: .fair, algorithm: .kMeansClustering)
            let sortedColors = allColors.sortedByGrayValue(isDesc: false)
            colorsSubject.send(Array(sortedColors.suffix(3)))
        } catch {
            Logger.log(error)
        }
    }
}
