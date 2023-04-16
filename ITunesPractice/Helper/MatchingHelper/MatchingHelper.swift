//
//  MatchingHelper.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import AVFAudio // 使用麥克風和捕捉音頻
import Combine
import UIKit
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

    var trackPublisher: AnyPublisher<Track?, Never> {
        trackSubject.eraseToAnyPublisher()
    }

    @Published var isRecording: Bool = false

    // MARK: Private

    // The ShazamKit session you’ll use to communicate with the Shazam service.
    private var session: SHSession?

    // An AVAudioEngine instance you’ll use to capture audio from the microphone.
    private let audioEngine = AVAudioEngine()

    private let audioSession = AVAudioSession.sharedInstance()

    private let trackSubject = CurrentValueSubject<Track?, Never>(nil)

    // 每秒採集多少個樣本，也就是赫茲(Hz)
    private let audioOutputSampleRate: Double = 44100.0

    // 音頻數據緩衝區大小，較小的緩衝區將具有更低的延遲，但可能會導致更多的 CPU 使用
    private let bufferSize: AVAudioFrameCount = 1024
}

extension MatchingHelper {
    /// 通過 ShazamKit 識別音頻
    /// - Parameters:
    ///  - catalog: 可以傳入自定義的目錄進行匹配
    func listenMusic(catalog: SHCustomCatalog? = nil) {
        // 創建 ShazamKit session
        if let catalog = catalog {
            session = SHSession(catalog: catalog) // 使用自定義目錄創建
        } else {
            session = SHSession()  // 使用 ShazamKit 預設的目錄創建
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
            // 開始捕獲音頻
            try audioEngine.start()
            isRecording = true
        } catch {
            Logger.log(message: error.localizedDescription)
        }
    }

    /// 停止錄音
    private func stopListening() {
        isRecording = false
        audioEngine.stop() // 停止錄音
        audioEngine.inputNode.removeTap(onBus: 0) // 移除音頻監聽器
        resetAudioSession()
    }

    /// 錄音並將緩衝區中的音頻轉換為 Shazam 簽名
    private func generateSignature() {
        // 音頻硬體裝置中輸入音訊的節點
        let inputNode = audioEngine.inputNode
        // 錄音的音頻格式
        let format = inputNode.outputFormat(forBus: .zero)

        // 創建一個"tap"（類似一個音頻的監聽器），以錄製/監聽/觀察該節點的輸出
        inputNode.installTap(onBus: .zero, bufferSize: bufferSize, format: format) { [weak session] buffer, audioTime in
            Logger.log(message: "recording......\(audioTime)")
            // 將緩衝區中的音頻轉換為 Shazam 簽名，並與所選目錄中的參考簽名相匹配。
            session?.matchStreamingBuffer(buffer, at: audioTime)
        }
    }

    /// 將 AVAudioSession 類別設置為錄音模式
    private func configureAudioSession() throws {
        try audioSession.setCategory(.record)
        // 告訴系統這個app即將使用音頻，因此需要讓其他app停止使用音頻，以避免出現衝突
        // 當音頻會話被停止時，系統會發出通知，告訴其他app可以再次使用音頻
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

    /// 請求麥克風權限的彈窗
    private func presentMicrophoneAccessAlert() {
        let title = "麥克風關閉".localizedString()
        let message = String(format: "%@ 無法聽取您正在收聽的內容。若要修復此問題，請允許 %@ 存取麥克風。".localizedString(), arguments: [AppInfo.appName, AppInfo.appName])

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { _ in
            alert.dismiss(animated: true)
        }
        let resetAction = UIAlertAction(title: "進入「設定」", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            alert.dismiss(animated: true)
        }
        alert.addAction(cancelAction)
        alert.addAction(resetAction)

        let rootVC = UIApplication.shared.rootViewController
        rootVC?.present(alert, animated: true)
    }
}

// MARK: SHSessionDelegate

extension MatchingHelper: SHSessionDelegate {
    // 匹配成功
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            match.mediaItems.forEach { item in
                print("__++++ matchItem:\n\(item.title ?? "")\n\(item.artist ?? "")\n\(item.artworkURL)\n")
            }
            let matchItem = match.mediaItems.first
            self.trackSubject.value = matchItem?.convertToTrack()
            self.stopListening()
        }
    }

    // 匹配失敗（沒有與查詢簽名匹配的歌曲，或發生阻止匹配的錯誤時觸發）
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.trackSubject.send(nil)
            self.stopListening()
            Logger.log(message: error?.localizedDescription)
        }
    }
}

// MARK: SHMatchedMediaItem

extension SHMatchedMediaItem {
    func convertToTrack() -> Track {
        return Track(
            artworkUrl100: artworkURL?.absoluteString ?? "",
            collectionName: "",
            artistName: artist ?? "",
            trackId: appleMusicID?.toInt() ?? 0,
            trackName: "",
            releaseDate: "",
            artistViewUrl: "",
            collectionViewUrl: "",
            previewUrl: "",
            trackViewUrl: appleMusicURL?.absoluteString ?? "")
    }
}
