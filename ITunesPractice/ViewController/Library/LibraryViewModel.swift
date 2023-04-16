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

//        UserDefaults.standard.publisher(for: \.tracks)
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                self.loadDataFromUserDefaults()
//            }
//            .store(in: &cancellables)
//
//        UserDefaults.standard.publisher(for: \.tracks)
//            .map { data in
//                // 轉換成自訂的 struct 陣列
//                let tracks = try? PropertyListDecoder().decode([Track].self, from: data)
//                return tracks ?? []
//            }
//             .assign(to: \.tracks, on: self)
//             .store(in: &cancellables)
    }

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
