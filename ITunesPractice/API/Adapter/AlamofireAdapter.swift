//
//  AlamofireAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Alamofire
import Foundation

public typealias Parameters = [String: Any]

/// 將 Alamofire 包起來的 Adapter，防止 Alamofire 散落在各個檔案
/// 這個階段，因為原來 Alamofire 直接使用原始檔，所以暫時還沒收起來
public final class AlamofireAdapter {

    private init() {}

    static let shared = AlamofireAdapter()

    func getSession() -> Session {
        return session
    }
    
    func getNetworkToolDataTask(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // 在 network tool 發動的 Alamofire session 有可能是在非 main queue 呼叫
        // 這會導致 event monitor crash，因 Alamofire 團隊直接寫了 fatalError 指令
        // 現在在這使用 URLSession

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        
        dataTask.resume()
        
        return dataTask
    }
    
    func getURLError(urlString: String) -> Error {
        return AFError.invalidURL(url: urlString)
    }
    
    func getNilDataError() -> Error {
        return AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
    }

    // MARK: Private

    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.timeoutIntervalForRequest
        return configuration
    }()
    
    private lazy var session: Session = {
        let eventMonitor = ApiEventMonitor()
        let session = Session(configuration: configuration, eventMonitors: [eventMonitor])
        return session
    }()
}

/// 加所有 header 的方法
extension AlamofireAdapter {
    /// 加上原來設定為 default 的 content-type, default is application/json
    static func addDefaultContentHeader(_ request: URLRequest) -> URLRequest {
        var returnRequest = request
        
        returnRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return returnRequest
    }
    
    static func addAcceptAllHeader(_ request: URLRequest) -> URLRequest {
        var returnRequest = request
        returnRequest.addValue("*/*", forHTTPHeaderField: "Accept")
        return returnRequest
    }
    
    static func addJsonPatchContentType(_ request: URLRequest) -> URLRequest {
        var returnRequest = request
        returnRequest.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        return returnRequest
    }
    
    static func addTextPlain(_ request: URLRequest) -> URLRequest {
        var returnRequest = request
        returnRequest.addValue("text/plain", forHTTPHeaderField: "Accept")
        return returnRequest
    }
    
    static func addFormURLEncoded(_ request: URLRequest) -> URLRequest {
        var returnRequest = request
        returnRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return returnRequest
    }
    
    static func add(_ request: URLRequest, jwtToken: String) -> URLRequest {
        var returnRequest = request
        let auth = HTTPHeader.authorization(bearerToken: jwtToken)
        
        var headers = returnRequest.headers
        headers.add(auth)
        returnRequest.headers = headers
        
        return returnRequest
    }
}
