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

    init(displayMode: DisplayMode, playlist: Playlist?) {
        self.displayMode = displayMode
        self.playlist = UserDefaults.playlists.first { $0 == playlist } ?? Playlist()
        imageUrl = self.playlist.imageUrl ?? UserDefaults.placeholderUrls.randomElement()
        tracks = self.playlist.tracks
        name = self.playlist.name
    }

    // MARK: Internal

    enum CellType {
        case addTrack
        case track
    }

    private(set) var selectedTrack: Track?
    private(set) var playlist: Playlist
    var name: String = ""

    @Published var displayMode: DisplayMode
    @Published var imageUrl: URL?
    @Published var tracks: [Track] = []

    var currentTrackIndexPublisher: AnyPublisher<Int, Never> {
        musicPlayer.currentTrackIndexPublisher
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        musicPlayer.isPlayingPublisher
    }

    var isEdited: Bool {
        playlist.imageUrl != imageUrl
            || playlist.name != name
            || playlist.tracks != tracks
    }

    var prefixItemCount: Int {
        displayMode == .normal ? 0 : 1
    }

    var totalCount: Int {
        tracks.count + prefixItemCount
    }

    var isPlaying: Bool {
        musicPlayer.isPlaying
    }

    func cellType(forCellAt index: Int) -> CellType {
        switch index {
        case 0:
            return displayMode == .normal ? .track : .addTrack
        default:
            return .track
        }
    }

    func track(forCellAt index: Int) -> Track? {
        guard tracks.indices.contains(index - prefixItemCount) else { return nil }
        return tracks[index - prefixItemCount]
    }

    func setSelectedTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index - prefixItemCount) else { return }
        selectedTrack = tracks[index - prefixItemCount]
    }

    func removeTrack(forCellAt index: Int) {
        guard tracks.indices.contains(index - prefixItemCount) else { return }
        tracks.remove(at: index - prefixItemCount)
    }

    func savePlaylist() {
        playlist.tracks = tracks
        playlist.imageUrl = imageUrl
        playlist.name = name.isEmpty ? "未命名播放列表" : name

        if displayMode == .add {
            Playlist.addPlaylist(playlist)
        } else if displayMode == .edit {
            Playlist.updatePlaylist(playlist)
        }
    }

    func toggleDisplayMode() {
        displayMode = displayMode == .normal ? .edit : .normal
    }

    /// 更換播放清單並播放指定音樂
    func refreshPlaylistAndPlaySong(at index: Int) {
        let trackIndex = max(0, index - prefixItemCount)
        guard trackIndex < playlist.tracks.count else { return }
        musicPlayer.refreshPlaylistAndPlaySong(playlist, at: trackIndex)
    }

    func appendTracks(newTracks: [Track]) {
        tracks.append(contentsOf: newTracks)
    }

    // MARK: Private

    private let musicPlayer: MusicPlayer = .shared
    private var cancellables: Set<AnyCancellable> = .init()
}
