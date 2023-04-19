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
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: .toBePlayedTracksDidChanged, object: nil)
    }

    // MARK: Internal

    @Published var tracks: [Track] = UserDefaults.standard.tracks

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        selectedTrack = tracks[index]
    }

    // MARK: Private

    private(set) var selectedTrack: Track?

    @objc
    private func userDefaultsDidChange() {
        tracks = UserDefaults.standard.tracks
    }
}
