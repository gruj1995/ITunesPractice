//
//  AddPlaylistViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Combine
import Foundation

class AddPlaylistViewModel {
    // MARK: Lifecycle

    init(_ playlist: Playlist?) {
        self.playlist = playlist ?? Playlist()
        tracks = self.playlist.tracks
        imageUrl = self.playlist.imageUrl
        name = self.playlist.name
    }

    // MARK: Internal

    var assetLocalIdentifier: String?

    private(set) var selectedTrack: Track?

    var playlist: Playlist

    @Published var imageUrl: URL?
    @Published var tracks: [Track] = []

    var name: String = ""

    var isEdited: Bool {
        playlist.imageUrl != imageUrl
        || playlist.name != name
        || playlist.tracks != tracks
    }

    var totalCount: Int {
        tracks.count + 2
    }

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index - 2) else { return nil }
        return tracks[index - 2]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index - 2) else { return }
        selectedTrack = tracks[index - 2]
    }

    func removeTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index - 2) else { return }
        tracks.remove(at: index - 2)
    }

    func savePlaylist() {
        playlist.tracks = tracks
        playlist.imageUrl = imageUrl
        playlist.name = name.isEmpty ? "未命名播放列表" : name

        if let row = UserDefaults.playlists.firstIndex(where: { $0.id == playlist.id }) {
            UserDefaults.playlists[row] = playlist
        } else {
            let newPlaylist = playlist.autoIncrementID()
            UserDefaults.playlists.append(newPlaylist)
        }
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()
}
