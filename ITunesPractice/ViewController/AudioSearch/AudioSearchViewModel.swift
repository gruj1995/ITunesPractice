//
//  AudioSearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import Foundation

class AudioSearchViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    @Published var tracks: [Track] = []

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    func loadTracksFromUserDefaults() {
        // Load the latest data from UserDefaults and update the ViewModel state.
        let storedTracks = UserDefaults.standard.tracks
        if tracks != storedTracks {
            tracks = storedTracks
        }
    }
}
