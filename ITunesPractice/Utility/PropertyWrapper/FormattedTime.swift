//
//  FormattedTime.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/2.
//

import Foundation

// 音樂播放時間格式
@propertyWrapper
struct FormattedTime {
    // MARK: Lifecycle

    init(showsSign: Bool = true) {
        self.showsSign = showsSign
        self.time = nil
    }

    // MARK: Internal

    var showsSign: Bool = true

    var wrappedValue: Float? {
        get { time }
        set { time = newValue }
    }

    var projectedValue: String {
        guard let time = time else { return "--:--" }
        let sign = showsSign && time < 0 ? "-" : ""
        let minutes = Int(abs(time)) / 60
        let seconds = Int(abs(time)) % 60
        return "\(sign)\(minutes):\(String(format: "%02d", seconds))"
    }

    // MARK: Private

    private var time: Float?
}
