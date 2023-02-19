//
//  ApiEventMonitor.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Alamofire
import Foundation

/// EventMonitor 是 Alamofire 的 protocol，在初始化 Session 的時候，就要初始化 EventMonitor
/// 並把 EventMonior 塞入 Session 的初始化參數中，若 Request 使用 Alamofire Session 發出時
/// 可以在不同生命週期，得到 Request 在不同階段的資料
/// https://www.raywenderlich.com/11668143-alamofire-tutorial-for-ios-advanced-usage#toc-anchor-002

final class ApiEventMonitor: EventMonitor {
    let queue = DispatchQueue(label: "ApiEventMonitor")

    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
//        Logger.log("This is event monitor, request started recording: \(request.description)")
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
//        Logger.log("This is event monitor, request did parsed, id: \(request.id), result: \(response)")
        guard let data = response.data else {
            return
        }
        if let json = try? JSONSerialization
            .jsonObject(with: data, options: .mutableContainers)
        {
            Logger.log(json)
        }
    }

    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
//        Logger.log("This is event monitor, request did complete, id: \(request.id), HTTPURLResponse code: \(request.response?.statusCode ?? 0)")
    }

    func request(_ request: Request, didGatherMetrics metrics: URLSessionTaskMetrics) {
//        Logger.log("This is did gather metrics: \(metrics.description)")
    }

    // Event called when a `Request` finishes and response serializers are being called.
    func requestDidFinish(_ request: Request) {
        Logger.log(request.description)
    }
}
