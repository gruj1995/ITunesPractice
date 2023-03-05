//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Combine
import UIKit

class SearchViewModel {
    // MARK: Lifecycle

//    var trackListSubgect: CurrentValueSubject = CurrentValueSubject<TrackList, Never>(TrackList(results: []))

    init() {
        $searchTerm
            .debounce(for: 0.3, scheduler: RunLoop.main) // 延遲觸發搜索操作
            .removeDuplicates() // 避免在使用者輸入相同的搜索文字時重複執行搜索操作
            .sink { keyWordValue in
                self.search(by: keyWordValue)
            }.store(in: &cancellables)
    }

    // MARK: Internal

    @Published var tracks: [Track] = []
    @Published var searchTerm: String = ""
    private(set) var selectedTrack: Track?

    func setSelectedTrack(forCellAt index: Int) {
        guard index < tracks.count else { return }
        selectedTrack = tracks[index]
    }

    func contextMenuConfiguration(forCellAt indexPath: IndexPath) -> UIContextMenuConfiguration {
        setSelectedTrack(forCellAt: indexPath.row)

        let configuration = TrackContextMenuConfiguration(index: indexPath.row, track: selectedTrack) { menuAction in
            switch menuAction {
            case .addToLibrary(let track):
                var storedTracks = UserDefaults.standard.tracks
                storedTracks.appendIfNotContains(track)
                UserDefaults.standard.tracks = storedTracks
            case .deleteFromLibrary(let track):
                var storedTracks = UserDefaults.standard.tracks
                storedTracks.removeAll(where: { $0 == track })
                UserDefaults.standard.tracks = storedTracks
            case .share(let track):
                guard let sharedUrl = URL(string: track.trackViewUrl) else {
                    Logger.log("Shared url is nil")
                    return
                }
                let vc = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
                UIApplication.shared.keyWindowCompact?.rootViewController?.present(vc, animated: true)
                return
            }
        }

        return configuration.createContextMenuConfiguration()
    }

    func search(by searchTerm: String) {
        guard !searchTerm.isEmpty else {
            return tracks = []
        }
        // TODO: 防止重複呼叫（需要嗎？）
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true

        let request = ITunesService.SearchRequest(term: searchTerm, limit: limit, offset: 0)
        request.fetchTracks { [weak self] result in
            guard let self = self else { return }
            self.isFetchInProgress = false
            switch result {
            case .success(let response):
                self.tracks = response.results
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }

    // MARK: Private

    private let limit: Int = 10

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []
    private var isFetchInProgress = false
}

// func search(){
//
//    //        request.send { (albums, response, error) in
//    //            if let error = error {
//    //                completion(.failure(error))
//    //            }
//    //            print("_+++ albums \(albums)")
//    //            completion(.success(true))
//    //        }
//    //
//    //        ApiSendHelper(request).send { result in
//    //            print("_+++ result \(result)")
//    //            switch result {
//    //            case .success:
//    //                let json = JSON(result)
//    //                print("_+++ \(result)")
//    //                completion(.success(true))
//    //            case .failure(let error):
//    //                completion(.failure(error))
//    //            }
//    //        }
// }
