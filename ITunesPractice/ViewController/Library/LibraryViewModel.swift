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
        UserDefaults.$playlists
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] playlists in
                self?.playlists = playlists
            }.store(in: &cancellables)

        UserDefaults.playlists = []
        for i in 0..<9 {
            UserDefaults.playlists.append(Playlist(name: "測試標題\(i)", description: "測試文案", tracks: []))
        }
    }

    // MARK: Internal

    @Published var playlists: [Playlist] = UserDefaults.playlists

    // 單選
    private(set) var selectedPlaylist: Playlist?

    var totalCount: Int {
        playlists.count
    }

    func item(forCellAt index: Int) -> Playlist? {
        guard playlists.indices.contains(index) else { return nil }
        return playlists[index]
    }

    func setSelectedItem(forCellAt index: Int) {
        guard playlists.indices.contains(index) else { return }
        selectedPlaylist = playlists[index]
    }

    func removeItem(forCellAt index: Int) {
        guard playlists.indices.contains(index) else { return }
        UserDefaults.playlists.remove(at: index)
        playlists = UserDefaults.playlists
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()
}
