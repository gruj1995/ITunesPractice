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

    init() {
        self.time = nil
    }

    // MARK: Internal

    var isNegative: Bool = false

    var wrappedValue: Float? {
          get { time }
          set { time = newValue }
      }

      var projectedValue: String {
          guard let time = time else { return "--:--" }
          let minutes = Int(time) / 60
          let seconds = Int(time) % 60
          return "\(minutes):\(String(format: "%02d", abs(seconds)))"
      }

    // MARK: Private

    private var time: Float?
}
