//
//  MatchingHelper.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import AVFAudio // 使用麥克風和捕捉音訊
import Combine
import ShazamKit

// MARK: - MatchingHelper

/// 透過麥克風錄音再用 ShazamKit 發送 Api 查詢匹配的歌曲
class MatchingHelper: NSObject {
    // MARK: Lifecycle

    private override init() {
        super.init()
    }

    // MARK: Internal

    static let shared = MatchingHelper()

    // 音量閥值
    private(set) var thresholdVolume: Float = 63.0

    var trackPublisher: AnyPublisher<Track?, Never> {
        trackSubject.eraseToAnyPublisher()
    }

    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        isRecordingSubject.eraseToAnyPublisher()
    }

    var volumePublisher: AnyPublisher<Float, Never> {
        volumeSubject.eraseToAnyPublisher()
    }

    var isRecording: Bool {
        get { isRecordingSubject.value }
        set { isRecordingSubject.value = newValue }
    }

    /// 在 AppDelegate 呼叫，讓 MusicPlayer 在開啟app時就建立
    func configure() {}

    // MARK: Private

    // 是否更新過音量閥值(透過取樣並濾除環境噪音取得)
    private var isThresholdVolumeUpdated: Bool = false

    // The ShazamKit session you’ll use to communicate with the Shazam service.
    private var session: SHSession?

    // An AVAudioEngine instance you’ll use to capture audio from the microphone.
    private let audioEngine = AVAudioEngine()

    private let audioSession = AVAudioSession.sharedInstance()

    // 取樣速率: 一秒內取得音訊樣本的次數，多數數位音訊的取樣速率是 44.1kHz
    private let audioOutputSampleRate: Double = 44100.0

    // 音訊資料緩衝區大小，較小的緩衝區將具有更低的延遲，但可能會導致更多的 CPU 使用
    private let bufferSize: Int = 1024

    private let trackSubject = CurrentValueSubject<Track?, Never>(nil)
    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    private let volumeSubject = CurrentValueSubject<Float, Never>(0)
}

extension MatchingHelper {
    /// 通過 ShazamKit 識別音訊
    /// - Parameters:
    ///  - catalog: 可以傳入自定義的目錄進行匹配
    func startListening(catalog: SHCustomCatalog? = nil) {
        // 創建 ShazamKit session
        if let catalog = catalog {
            session = SHSession(catalog: catalog) // 使用自定義目錄創建
        } else {
            session = SHSession() // 使用 ShazamKit 預設的目錄創建
        }

        session?.delegate = self

        // 請求麥克風錄音權限
        audioSession.requestRecordPermission { [weak self] success in
            guard let self else { return }
            if success {
                // 使用者同意的話進入辨識流程
                self.startRecognition()
            } else {
                // 使用者不同意的話需要請求權限
                DispatchQueue.main.async {
                    self.presentMicrophoneAccessAlert()
                }
            }
        }
    }

    /// 進入辨識流程
    private func startRecognition() {
        // 檢查是否正在錄音，是的話暫停錄音
        if audioEngine.isRunning {
            stopListening()
            return
        }

        do {
            try configureAudioSession()
            generateSignature()

            // 預先配置資源，避免延遲或卡頓
            audioEngine.prepare()
            // 開始捕獲音訊
            try audioEngine.start()
            isRecording = true
        } catch {
            Logger.log(message: error.localizedDescription)
        }
    }

    /// 停止錄音
    func stopListening() {
        isRecording = false
        isThresholdVolumeUpdated = false
        audioEngine.stop() // 停止錄音
        audioEngine.inputNode.removeTap(onBus: 0) // 移除音訊監聽器
        resetAudioSession()
    }

    /// 錄音並將緩衝區中的音訊轉換為 Shazam 簽名
    private func generateSignature() {
        // 音訊硬體裝置中輸入音訊的節點
        let inputNode = audioEngine.inputNode
        // 錄音的音訊格式
        let format = inputNode.outputFormat(forBus: .zero)

        // 創建一個"tap"（類似一個音訊的監聽器），以錄製/監聽/觀察該節點的輸出
        inputNode.installTap(onBus: .zero, bufferSize: AVAudioFrameCount(bufferSize), format: format) { [weak self] buffer, audioTime in
            guard let self else { return }
            Logger.log(message: "recording......\(audioTime)")

            // 確認是否需更新閥值音量
//            if !self.isThresholdVolumeUpdated {
//                self.thresholdVolume = self.getThresholdVolume(from: buffer, bufferSize: self.bufferSize)
//                print("___+++ 音量閥值 \(self.thresholdVolume)")
//                self.isThresholdVolumeUpdated.toggle()
//            }

            // 將緩衝區中的音訊轉換為 Shazam 簽名，並與所選目錄中的參考簽名相匹配。
            self.session?.matchStreamingBuffer(buffer, at: audioTime)
            // 觀察音量變化
            self.notifyVolumeThresholdExceeded(buffer: buffer, bufferSize: Int(self.bufferSize))
        }
    }

    /// 音量超出閥值就發送通知事件
    private func notifyVolumeThresholdExceeded(buffer: AVAudioPCMBuffer, bufferSize: Int) {
        guard let rawDataPointer = buffer.floatChannelData?.pointee else {
            Logger.log("音訊緩衝區無法轉換為 Float")
            return
        }
        let sampleCount = Int(buffer.frameLength)
        let bufferPointer = UnsafeBufferPointer(start: rawDataPointer, count: sampleCount)

        // 取得緩衝區中所有樣本資料的 RMS (用來判斷音訊的強度和音量大小)
        // RMS（Root Mean Square）是透過在一段時間內，將所有音訊樣本平方後取平均值再取根號所得到的值
        let rms = sqrt(bufferPointer.map { pow($0, 2) }.reduce(0, +) / Float(bufferPointer.count))
        // 將 RMS 值轉換為分貝 (dB) 值
        let decibels = 20 * log10(rms)

        // 超過一定分貝才傳送事件
        if decibels > thresholdVolume {
            DispatchQueue.main.async {
                self.volumeSubject.send(decibels)
            }
        }
    }

    /// 將 AVAudioSession 類別設置為錄音模式
    private func configureAudioSession() throws {
        try audioSession.setCategory(.record)
        // 告訴系統這個app即將使用音訊，因此需要讓其他app停止使用音訊，以避免出現衝突
        // 當音訊會話被停止時，系統會發出通知，告訴其他app可以再次使用音訊
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    /// 將 AVAudioSession 類別設置回支援背景播放音樂的模式
    private func resetAudioSession() {
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback)
        } catch {
            Logger.log(message: "Error resetting audio session: \(error.localizedDescription)")
        }
    }
}

// MARK: SHSessionDelegate

extension MatchingHelper: SHSessionDelegate {
    // 匹配成功
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            // mediaItem 內其實包含專輯名稱、發行日期等資訊，但不知道為什麼沒開放外部取用
            let mediaItem = match.mediaItems.first
            let track = mediaItem?.convertToTrack()
            self.trackSubject.value = track
            self.stopListening()
        }
    }

    // 匹配失敗（沒有與查詢簽名匹配的歌曲，或發生阻止匹配的錯誤時觸發）
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.trackSubject.send(nil)
            self.stopListening()
            Logger.log(message: error?.localizedDescription)
        }
    }
}
