//
//  ApiEngine+ApiComponentSendable.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation
import Alamofire

// MARK: - ApiComponentSendable
extension ApiEngine: ApiComponentSendable {
    
    public func sendRequest(request: URLRequest, queue: DispatchQueue = .main, handler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask?{
        let authorizationHeaderPreservingRedirectHandler: Redirector = {
            let behavior = Redirector.Behavior.modify { (task, request, response) in
                var redirectedRequest = request
                
                if let originalRequest = task.originalRequest,
                   let headers = originalRequest.allHTTPHeaderFields {
                    headers.forEach { element in
                        redirectedRequest.setValue(element.value, forHTTPHeaderField: element.key)
                    }
                }
                return redirectedRequest
            }
            
            let redirector = Redirector(behavior: behavior)
            return redirector
        }()
        
        
        // 因為現在在 session 中插入 event monitor，但如果 request 不在 main 上，event monitor 在 Alamofire 內會有可能拿不到而進入 fatal task
        if Thread.isMainThread {
            
            let dataRequest = session.request(request)
                .validate(statusCode: 200..<300)
                .redirect(using: authorizationHeaderPreservingRedirectHandler)
                .responseData(queue: queue) { (responseData) in
                    let data = responseData.data
                    let response = responseData.response
                    let error = responseData.error
                    
                    handler(data, response, error)
                }
            return dataRequest.task as? URLSessionDataTask
            
        } else {
            
            let dataRequest = session.request(request)
            DispatchQueue.main.async {
                
                dataRequest
                    .validate(statusCode: 200..<300)
                    .responseData(queue: queue) {
                        (responseData) in
                        
                        let data = responseData.data
                        let response = responseData.response
                        let error = responseData.error
                        
                        handler(data, response, error)
                    }
            }
            return dataRequest.task as? URLSessionDataTask
        }
    }
}
