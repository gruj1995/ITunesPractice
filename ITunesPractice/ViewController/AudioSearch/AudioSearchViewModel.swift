//
//  AudioSearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import Foundation

class AudioSearchViewModel {

    @Published var searchStage: MusicSearchStage = .none

    // 22秒  6、7、5 3 1
    private var timer: Timer?
    var timeElapsed = 0

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    @objc
    private func timerFired() {
        timeElapsed += 1

        switch timeElapsed {
        case 6, 13, 18, 21, 23:
            // 触发事件的代码
            print("Event triggered at \(timeElapsed) seconds")
            searchStage = searchStage.next()
        default:
            break
        }

        if timeElapsed == 23 {
            stopTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeElapsed = 0
    }

    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var track: Track?

    let matchingHelper = MatchingHelper.shared

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    var trackPublisher: AnyPublisher<Track?, Never> {
        matchingHelper.trackPublisher
    }

    /// 開始錄音進行辨識
    func listenMusic() {
        searchStage = .listening
        startTimer()
        matchingHelper.listenMusic()
    }
}
