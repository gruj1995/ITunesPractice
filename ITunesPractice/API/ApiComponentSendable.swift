//
//  ApiComponentSendable.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

// MARK: - ApiComponent發送器
public protocol ApiComponentSendable {
    func sendRequest(request: URLRequest, queue: DispatchQueue, handler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask?
    func didSendRequestEvent(requestName: String)
    func didReceiveResponseEvent(requestName: String, executionTime: Double)
}

// MARK: - ApiComponent發送器 - 預設不實作的方法
extension ApiComponentSendable {
    public func didSendRequestEvent(requestName: String) {}
    public func didReceiveResponseEvent(requestName: String, executionTime: Double) {}
}

// MARK: - ApiComponent發送器 - 發送方法
extension ApiComponentSendable {
    
    func genRequest<Req: CustomRequest>(request: Req) -> URLRequest? {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildRequest()
            return urlRequest
        } catch {
            return nil
        }
    }
    
    func sendRequest<Req: CustomRequest>(
        urlRequest: URLRequest,
        request: Req,
        queue: DispatchQueue,
        handler: @escaping (Swift.Result<Req.Response, ApiEngineError>) -> Void) -> URLSessionDataTask? {

        Logger.log("🌐 [\(Req.self)][\(urlRequest.method?.rawValue ?? "")]: \(urlRequest.url?.absoluteString.removingPercentEncoding ?? "")")

        // 發送Request
        let dataTask = sendRequest(request: urlRequest, queue: queue) { (data, response, error) in
         
            // 錯誤: 有Error
            if let error = error {
                Logger.log("📦 [\(Req.self)][ReceiveError]: \(error)")
                handler(.failure(ApiEngineError(data: data, error: error, response: response)))
                return
            }
            
            // 錯誤: 沒有Response
            guard let response = response else {
                handler(.failure(ApiEngineError(data: data, error: error, response: nil)))
                return
            }
            
            let dataStr: String = {
                if let data = data {
                    return String(data: data, encoding: .utf8) ?? "No Utf8 Data.(無法解析!!)"
                } else {
                    return "Data Nil.(沒有Data!!)"
                }
            }()
            Logger.log("📦 [\(Req.self)][StatusCode = \(response.statusCode)][ReceiveData]: " + dataStr.prefix(100))
            
            if let result = response as? Req.Response {
                handler(.success(result))
            }
            // TODO: 修正
//            guard let data = data else {
//                handler(.failure(ApiEngineError(data: nil, error: error, response: response)))
//                return
//            }
//            
//            do {
//                let value = try JSONDecoder().decode(Req.Response.self, from: data)
//                handler(.success(value))
//            } catch {
//                handler(.failure(ApiEngineError(data: data, error: error, response: response)))
//            }
        }
        return dataTask
    }
}
