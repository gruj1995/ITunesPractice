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

    // TODO: 為什麼PassthroughSubject只觸發一次？
    var colorsSubject = CurrentValueSubject<[UIColor], Never>(DefaultTrack.gradientColors)

    var selectedIndexPath: IndexPath?

    // MARK: - Outputs

    var selectedTrack: Track? {
        get {
            musicPlayer.currentTrack
        }
        set {
            if let index = tracks.firstIndex(where: { $0 == newValue }) {
                musicPlayer.currentTrackIndex = index
                changeImage()
            }
        }
    }

    var state: ViewState {
        get {
            return stateSubject.value
        }
        set {
            stateSubject.value = newValue
        }
    }

    var statePublisher: AnyPublisher<ViewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    var tracks: [Track] {
        musicPlayer.tracks
    }

    var totalCount: Int {
        return tracks.count
    }

    var numberOfSections: Int {
        1
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
        selectedTrack = tracks[index]
        musicPlayer.play(track: tracks[index])
    }

    // MARK: MusicPlayer

    func toggleShuffleMode() {
        musicPlayer.toggleShuffleMode()
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Inputs

    private let musicPlayer: MusicPlayer = .shared

    // 當歌曲被選中時，通過這個Subject發布選中事件
    private let selectTrackPublisher = CurrentValueSubject<Track?, Never>(nil)
    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)

    private var currentPage: Int = 0
    private var totalPages: Int = 0
    private var pageSize: Int = 20

//    private func setSelectedTrack(_ track: Track?) {
//        selectedTrack = track
//    }

    private func changeImage() {
        downloadImage(with: selectedTrack?.artworkUrl100)
    }

    /// 使用kingfisher下載圖檔
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
