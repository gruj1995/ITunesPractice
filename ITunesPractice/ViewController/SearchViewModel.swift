//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import Combine
import UIKit

// MARK: - SearchViewModel

class SearchViewModel {
    // MARK: Lifecycle

    init() {
        searchTermSubject
            .debounce(for: 0.3, scheduler: RunLoop.main) // 延遲觸發搜索操作
            .removeDuplicates() // 避免在使用者輸入相同的搜索文字時重複執行搜索操作
            .sink { [weak self] term in
                self?.searchTrack(with: term)
            }.store(in: &cancellables)
    }

    // MARK: Internal

    private(set) var selectedTrack: Track?

    var searchTerm: String {
        get {
            return searchTermSubject.value
        }
        set {
            searchTermSubject.value = newValue
        }
    }

    var state: ViewState {
        get {
            return stateSubject.value
        }
        set {
            stateSubject.value = newValue
        }
    }

    var statePublisher: AnyPublisher<ViewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    var tracksPublisher: AnyPublisher<[Track], Error> {
        return tracksSubject.eraseToAnyPublisher()
    }

    var tracks: [Track] {
        get {
            tracksSubject.value
        }
        set {
            tracksSubject.value = newValue
        }
    }

    var totalCount: Int {
        return tracks.count
    }

    func track(forCellAt index: Int) -> Track? {
        guard index < tracks.count else { return nil }
        return tracks[index]
    }

    func loadNextPage() {
//        guard currentPage < totalPages || totalPages == 0 else { return }
        guard !searchTerm.isEmpty else {
            tracks.removeAll()
            return
        }

        if case .loading = state {
            return // 避免同時載入多次
        }
        state = .loading

        let offset = currentPage * pageSize
        let request = ITunesService.SearchRequest(term: searchTerm, limit: pageSize, offset: offset)

        request.fetchTracksByURLSession { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.currentPage += 1
                self.totalPages = response.resultCount / self.pageSize + 1
                self.tracks.append(contentsOf: response.results)
                self.state = .success
            case .failure(let error):
                Logger.log(error.localizedDescription)
                self.state = .failed(error: error)
            }
        }
    }

    /// 設定選取的歌曲
    func setSelectedTrack(forCellAt index: Int) {
        guard index < tracks.count else { return }
        selectedTrack = tracks[index]
    }

    /// 為cell創建context menu configuration
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

    // MARK: Private

    private let tracksSubject = CurrentValueSubject<[Track], Error>([])
    private let searchTermSubject = CurrentValueSubject<String, Never>("")
    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)

    private var currentPage: Int = 0
    private var totalPages: Int = 0
    private var pageSize: Int = 20

    private var cancellables: Set<AnyCancellable> = []

    // TODO: 搜尋某些字詞 ex: de 會壞掉
    // 回傳404，錯誤訊息 Your request produced an error. [newNullResponse]
    private func searchTrack(with term: String) {
        searchTerm = term
        currentPage = 0
        totalPages = 0
        tracks.removeAll()
        loadNextPage()
    }
}
