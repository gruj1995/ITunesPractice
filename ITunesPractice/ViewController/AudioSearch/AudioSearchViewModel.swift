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

    @Published var searchStage: MusicSearchStage = .none

    var isRecording: Bool {
        matchingHelper.isRecording
    }
    
    var thresholdVolume: Float {
        matchingHelper.thresholdVolume
    }

    var trackPublisher: AnyPublisher<Track?, Never> {
        matchingHelper.trackPublisher
    }

    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        matchingHelper.isRecordingPublisher
    }

    var volumePublisher: AnyPublisher<Float, Never> {
        matchingHelper.volumePublisher
    }

    /// 開始錄音進行音樂辨識
    func startRecognition() {
        startTimer()
        searchStage = .listening
        matchingHelper.startListening()
    }

    /// 結束音樂辨識
    func stopRecognition() {
        stopTimer()
        searchStage = .none
        matchingHelper.stopListening()
    }

    // MARK: Private

    private let matchingHelper = MatchingHelper.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var timeElapsed = 0

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeElapsed = 0
    }

    // TODO: 目前是觀察 Shazam app 找歌大約花 22 秒，但實測 call app 好像不到那麼久就會回傳結果，可能他們有做重試的機制。這邊要再看看怎麼改得更適合點
    @objc
    private func timerFired() {
        timeElapsed += 1

        switch timeElapsed {
        case 6, 13, 18, 21, 23:
            Logger.log("Event triggered at \(timeElapsed) seconds")
            searchStage = searchStage.next()
        default:
            break
        }

        if timeElapsed == 23 {
            stopTimer()
        }
    }
}
