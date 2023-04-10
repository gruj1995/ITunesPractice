//
//  TrackDetailViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/28.
//

import Combine
import Foundation

class TrackDetailViewModel {
    // MARK: Lifecycle

    init(trackId: Int?) {
        lookup(trackId: trackId)
    }

    // MARK: Internal

    @Published
    private(set) var track: Track?

    var selectedPreviewType: PreviewType?

    var urlString: String? {
        switch selectedPreviewType {
        case .artist: return track?.artistViewUrl
        case .album: return track?.collectionViewUrl
        case .track: return track?.previewUrl
        default: return nil
        }
    }

    // MARK: Private

    private func lookup(trackId: Int?) {
        guard let trackId = trackId else { return }
        let request = ITunesService.LookupRequest(trackId: trackId)
        request.fetchTrack { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let track):
                self.track = track
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }
}
