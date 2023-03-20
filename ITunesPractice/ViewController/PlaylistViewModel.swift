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
        tracks = UserDefaults.standard.tracks
        setSelectedTrack(tracks.first)
    }

    // MARK: Internal

    let colorsSubject = PassthroughSubject<[UIColor], Never>()

    private(set) var selectedTrack: Track? {
        didSet {
            changeImage()
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

    var tracksPublisher: AnyPublisher<[Track], Error> {
        return tracksSubject.eraseToAnyPublisher()
    }

    var tracks: [Track] {
        get {
            tracksSubject.value
        }
        set {
            tracksSubject.value = newValue
        }
    }

    var totalCount: Int {
        return tracks.count
    }

    var numberOfSections: Int {
        2
    }

    func track(forCellAt index: Int) -> Track? {
        guard index < tracks.count else { return nil }
        return tracks[index]
    }

    /// 設定選取的歌曲
    func setSelectedTrack(forCellAt index: Int) {
        guard index < tracks.count else { return }
        selectedTrack = tracks[index]
    }

    func numberOfRows(in section: Int) -> Int {
        totalCount
    }

    // MARK: Private

    private let tracksSubject = CurrentValueSubject<[Track], Error>([])
    private let searchTermSubject = CurrentValueSubject<String, Never>("")
    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)

    private var currentPage: Int = 0
    private var totalPages: Int = 0
    private var pageSize: Int = 20

    private var cancellables: Set<AnyCancellable> = []

    private func setSelectedTrack(_ track: Track?) {
        selectedTrack = track
    }

    private func changeImage() {
        guard let track = selectedTrack else { return }
        downloadImage(with: track.artworkUrl100)
    }

    /// 使用kingfisher下載圖檔
    private func downloadImage(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                Logger.log("Image: \(value.image). Got from: \(value.cacheType)")
                self.generateColors(by: value.image)
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }

    /// 從圖檔提取出主要顏色，再依淺到深順序，取最深的3個顏色回傳
    private func generateColors(by image: UIImage) {
        do {
            let allColors = try image.dominantColors(with: .fair, algorithm: .kMeansClustering)
            let sortedColors = allColors.sortedByGrayValue(isDesc: false)
            colorsSubject.send(Array(sortedColors.suffix(3)))
        } catch {
            print(error)
        }
    }
}
