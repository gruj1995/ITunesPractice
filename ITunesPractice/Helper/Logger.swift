//
//  Logger.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

class Logger {
    
    static func log<T>(message: T, file: String = #file, method: String = #function) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName): \(method)] \(message)")
        #endif
    }
    
    /// 輸出訊息
    static func log<T>(_ message: T) {
        #if DEBUG
        print(message)
        #endif
    }
}
