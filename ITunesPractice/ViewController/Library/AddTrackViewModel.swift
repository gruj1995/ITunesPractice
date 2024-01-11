//
//  AddTrackViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/21.
//

import Combine
import Foundation

class AddTrackViewModel {
    // MARK: Lifecycle

    init() {
        allTracks = UserDefaults.defaultPlaylist.tracks

        $searchTerm
            .debounce(for: 0.3, scheduler: RunLoop.main) // 延遲觸發搜索操作(0.5s)
            .removeDuplicates() // 避免在使用者輸入相同的搜索文字時重複執行搜索操作
            .sink { [weak self] term in
                self?.searchTrack(with: term)
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var allTracks: [Track]
    @Published var filteredTracks: [Track] = []
    @Published var searchTerm: String = ""
    private(set) var selectedTracks: [Track] = []

    var totalCount: Int {
        filteredTracks.count
    }

    var isModified: Bool {
        !selectedTracks.isEmpty
    }

    func track(forCellAt index: Int) -> Track? {
        guard filteredTracks.indices.contains(index) else { return nil }
        return filteredTracks[index]
    }

    func toggleSelect(forCellAt index: Int) {
        guard let track = track(forCellAt: index) else { return }

        if isSelected(track) {
            removeSelectedTrack(track)
        } else {
            appendSelectedTrack(track)
        }
    }

    func appendSelectedTrack(_ track: Track) {
        selectedTracks.appendIfNotContains(track)
    }

    func removeSelectedTrack(_ track: Track) {
        selectedTracks.removeAll { $0 == track }
    }

    func isSelected(_ track: Track) -> Bool {
        selectedTracks.contains(track)
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()

    private func searchTrack(with term: String) {
        searchTerm = term
        filterTracks(term: term)
    }

    private func filterTracks(term: String) {
        if searchTerm.isEmpty {
            filteredTracks = allTracks
        } else {
            filteredTracks = allTracks.filter { track in
                track.trackName.contains(term)
            }
        }
    }
}
