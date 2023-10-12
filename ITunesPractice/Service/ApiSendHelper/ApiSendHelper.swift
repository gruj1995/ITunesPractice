//
//  ApiSendHelper.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

class ApiSendHelper<Req: CustomRequest> {
    
    private var request: Req
    private var queue: DispatchQueue = .main
    private var apiSender: ApiComponentSendable = ApiEngine.shared
 
    private(set) var dataTask: URLSessionDataTask? = nil
    
    /// 初始化
    init(_ request: Req) {
        self.request = request
    }
    
    /// 設定回應後的執行緒
    func setQueue(_ queue: DispatchQueue) -> Self {
        self.queue = queue
        return self
    }
    
    /// 設定Api發送者
    func setSender(_ apiSender: ApiComponentSendable) -> Self {
        self.apiSender = apiSender
        return self
    }
    
    /// 發送訊息
    func send(handler: @escaping (Swift.Result<Req.Response, ApiEngineError>) -> Void) {
        guard let urlRequest = apiSender.genRequest(request: request) else { return }
        dataTask = apiSender.sendRequest(urlRequest: urlRequest, request: request, queue: queue, handler: handler)
    }
}

