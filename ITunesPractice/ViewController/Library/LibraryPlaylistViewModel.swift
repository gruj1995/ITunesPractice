//
//  LibraryPlaylistViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Combine
import Foundation

class LibraryPlaylistViewModel {
    // MARK: Lifecycle

    init() {
        UserDefaults.$libraryTracks
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] tracks in
                self?.tracks = tracks
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var tracks: [Track] = UserDefaults.libraryTracks

    // 單選
    private(set) var selectedTrack: Track?

    // 多選
    var selectedTracks: [Track] {
        selectedIndicies.map { tracks[$0.row] }
    }

    var selectedIndicies: [IndexPath] = []

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        selectedTrack = tracks[index]
    }

    func removeTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        UserDefaults.libraryTracks.remove(at: index)
        tracks = UserDefaults.libraryTracks
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()
}