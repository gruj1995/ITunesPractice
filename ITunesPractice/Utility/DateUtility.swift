//
//  DateUtility.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Foundation

struct DateUtility {
    
    /// DateFormatter 耗能比較:
    /// Formatter 解析 Date 並生成字串 > 創建DateFormatter > 指定format格式
    /// 使用singleton節省重複創建DateFormatter
    static let dateFormatter = DateFormatter()
    
    /// 參考：https://blog.csdn.net/weixin_33717298/article/details/88703905
    static let iso8601DateFormatter = ISO8601DateFormatter()
    
    private var timeZone: TimeZone {
        return TimeZone(identifier: "Asia/Taipei") ?? TimeZone.current
    }
    
    /// 遇到日期計算一律使用 ISO8601 格式,不要用 Calendar.current
    var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = timeZone
        return calendar
    }
    
    /// 輸入 年 月 日, 如果是合法日期, return Date, 不然 return nil
    /// - Parameters:
    ///   - year: 年: Int
    ///   - month: 月: Int
    ///   - day: 日: Int
    func getDateFrom(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        
        var compoenents = DateComponents()
        compoenents.calendar = calendar
        compoenents.year = year
        compoenents.month = month
        compoenents.day = day
        compoenents.hour = hour
        compoenents.minute = minute
        compoenents.second = second
        
        if compoenents.isValidDate == false {
            return nil
        }
        return compoenents.date
    }
    
    /// return dateComponents,預設值為 年 月 日 時 分 秒, 可以改
    /// - Parameters:
    ///   - date: 目標 Date
    ///   - dateComponents: 預設值為 年 月 日 時 分 秒, 可以改
    func getDateComponentsFrom(date: Date, dateComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]) -> DateComponents {
           
           return calendar.dateComponents(dateComponents, from: date)
    }
    
    /// 比較兩個日期差異的天數
    func daysBetweenDate(from: Date, to: Date) -> Int {
        let components = calendar.dateComponents([.day], from: from, to: to)
        return components.day ?? 0
    }
    
    /// 判斷某日期是否在距今的指定天數內
    func isDateWithinDays(date: Date, withinDays: Int) -> Bool {
        let days = daysBetweenDate(from: date, to: Date())
        if days < withinDays {
            return true
        }
        return false
    }
    
    func getDateFromMs(ms: Int64) -> Date {
        
        let unixtime = ms / 1000
        
        return Date(timeIntervalSince1970: TimeInterval(unixtime))
    }
}
