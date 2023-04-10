//
//  Date+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

extension Date {
    func toString(dateFormat: String? = "yyyy/MM/dd HH:mm:ss", locale: Locale = .autoupdatingCurrent) -> String {
        let formatter = DateUtility.dateFormatter
        formatter.dateFormat = dateFormat
        formatter.locale = locale // Locale(identifier: "zh_Hant_TW")
        return formatter.string(from: self)
    }
}
