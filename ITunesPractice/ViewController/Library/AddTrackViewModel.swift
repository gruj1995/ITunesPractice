//
//  AddTrackViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/21.
//

import Foundation

class AddTrackViewModel {
    // MARK: Lifecycle

    init() {
        tracks = UserDefaults.defaultPlaylist.tracks
    }

    // MARK: Internal

    @Published var tracks: [Track] = []
    private(set) var selectedTracks: [Track] = []

    var totalCount: Int {
        tracks.count
    }

    var isModified: Bool {
        !selectedTracks.isEmpty
    }

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

    func toggleSelect(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        if isSelected(forCellAt: index) {
            removeSelectedTrack(forCellAt: index)
        } else {
            appendSelectedTrack(forCellAt: index)
        }
    }

    func appendSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        selectedTracks.appendIfNotContains(tracks[index])
        print("__+ selectedTracks: \(selectedTracks.map { $0.id })")
    }

    func removeSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index) else { return }
        selectedTracks.removeAll { $0 == tracks[index] }
        print("__+ selectedTracks: \(selectedTracks.map { $0.id })")
    }

    func isSelected(forCellAt index: Int) -> Bool {
        guard tracks.indices.contains(index) else { return false }
        return selectedTracks.contains(tracks[index])
    }
}
