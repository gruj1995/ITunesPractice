//
//  MatchingHelper+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/21.
//

import AVFAudio
import UIKit

extension MatchingHelper {
    /// 請求麥克風權限的彈窗
    func presentMicrophoneAccessAlert() {
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

    /// 取得音訊緩衝區的閾值音量
    /// 參考: https://developer.apple.com/forums/thread/710820
    ///
    /// - Parameters:
    ///   - buffer: AVAudioPCMBuffer，音訊緩衝區
    ///   - bufferSize: 緩衝區的大小
    /// - Returns: 閾值音量
    func getThresholdVolume(from buffer: AVAudioPCMBuffer, bufferSize: Int) -> Float {
        // 確保緩衝區的音訊數據存在
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0
        }

        // 將音訊數據轉換為陣列
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: bufferSize))

        // 計算信號包絡線（Envelope）
        var outEnvelope = [Float]()
        var envelopeState: Float = 0
        let envConstantAtk: Float = 0.16 // 攻擊時間常數
        let envConstantDec: Float = 0.003 // 釋放時間常數

        for sample in channelDataArray {
            let rectified = abs(sample)

            // 根據信號包絡線（Envelope）的變化來調整狀態
            if envelopeState < rectified {
                envelopeState += envConstantAtk * (rectified - envelopeState)
            } else {
                envelopeState += envConstantDec * (rectified - envelopeState)
            }
            outEnvelope.append(envelopeState)
        }

        /*
         在上述的程式碼中，使用了一種低通濾波器來過濾來自麥克風的噪聲，
         其截止頻率為 0.007，即只有低於這個頻率的訊號才能通過濾波器。
         這樣可以有效地減少來自麥克風的環境噪聲和電磁干擾的影響，提高音訊信號的品質和準確度。
         */

//        // 在濾波之後，如果音量的最大值大於0.015，則返回該最大值；否則，返回0.0
//        // 0.015 是一個經驗值，可以根據具體情況進行調整
//        if let maxVolume = outEnvelope.max(),
//           maxVolume > Float(0.015) {
//            return maxVolume
//        } else {
//            return 0.0
//        }

        // 將緩衝區內的音量平均值轉換成分貝數字
        outEnvelope.forEach { print("_+_+_+_+ \($0)") }
        let rootMeanSquare = sqrt(envelopeState)
        let soundLevel = 20 * log10(rootMeanSquare / 0.007)

        return soundLevel
    }
}
