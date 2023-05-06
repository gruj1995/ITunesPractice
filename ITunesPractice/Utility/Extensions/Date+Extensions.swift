//
//  Date+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow: Date { return Date().dayAfter }

    /// 午夜12:00
    var midnight: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// 前一天午夜12:00
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
    }

    /// 後一天午夜12:00
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
    }

    /// 日末(晚上11:59:59)
    var dayEnd: Date {
        var date = dayAfter
        date.addTimeInterval(-1)
        return date
    }

    func toString(dateFormat: String? = "yyyy/MM/dd HH:mm:ss", locale: Locale = .autoupdatingCurrent) -> String {
        let formatter = DateUtility.dateFormatter
        formatter.dateFormat = dateFormat
        formatter.locale = locale // Locale(identifier: "zh_Hant_TW")
        return formatter.string(from: self)
    }
}
