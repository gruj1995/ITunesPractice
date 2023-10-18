//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import Combine
import Foundation

// MARK: - SearchViewModel

class SearchViewModel {

    // MARK: Internal

    let app: AppModel = AppModel.shared

    init() {

    }

    private func getTracks() {
        do {
            let mp3Files = try FileManager.default.contentsOfDirectory(at: app.mp3DocumentUrl, includingPropertiesForKeys: nil, options: [])
            let mp3Songs = mp3Files.filter { $0.pathExtension.lowercased() == "mp3" }
            for mp3SongURL in mp3Songs {
                print("歌曲文件：\(mp3SongURL.lastPathComponent)")
            }
        } catch {
            Logger.log("无法获取歌曲文件列表：\(error)")
        }
    }

    var statePublisher: AnyPublisher<ViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func updateHistoryItems(term: String?) {
        guard let term else { return }
        if let index = UserDefaults.historyItems.firstIndex(of: term) {
            UserDefaults.historyItems.remove(at: index)
        }
        UserDefaults.historyItems.insert(term, at: 0)
    }

    // MARK: Private

    private let stateSubject = CurrentValueSubject<ViewState, Never>(.none)
    private var state: ViewState {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }
    private var cancellables: Set<AnyCancellable> = .init()
}
