//
//  Double+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/26.
//

import Foundation

extension Double {
    /// 遇到 Nan 或無窮大時回傳 nil
    var floatValue: Float? {
        if self.isNaN || self.isInfinite {
            return nil
        }
        return Float(self)
    }

    var intValue: Int? {
        if self.isNaN || self.isInfinite {
            return nil
        }
        return Int(self)
    }

    var excludeNanOrInfiniteValue: Double? {
        if self.isNaN || self.isInfinite {
            return nil
        }
        return self
    }
}
