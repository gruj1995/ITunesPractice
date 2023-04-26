//
//  LibraryViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/3.
//

import Combine
import Foundation

class LibraryViewModel {
    // MARK: Lifecycle

    init() {
        // 觀察待播清單更新
        UserDefaults.$toBePlayedTracks
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.tracks = UserDefaults.toBePlayedTracks
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var tracks: [Track] = UserDefaults.toBePlayedTracks
    private(set) var selectedTrack: Track?

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        selectedTrack = tracks[index]
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()
}
