//
//  ApiEngine.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation
import Alamofire


public class ApiEngine {

    public static let shared = ApiEngine()

    lazy var session = AlamofireAdapter.shared.getSession()

    var baseUrlString: String {
        return Constants.domain
    }
    
    /// 開放外部修改 time out
    public func updateRequestTimeout(timeout: TimeInterval) {
        session.sessionConfiguration.timeoutIntervalForRequest = timeout
        session.sessionConfiguration.timeoutIntervalForResource = timeout
    }

    // MARK: - Request with URLRequest
    
    /// Request with URLRequest - completion 回傳物件 (Data?, URLResponse?, Error?)
    @discardableResult
    public func request(_ request: URLRequest,
                        queue: DispatchQueue = .main,
                        completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> DataRequest {

        Logger.log("🌐 [\(request.method?.rawValue ?? "") Url]: \(request.url?.absoluteString.removingPercentEncoding ?? "")")

        return session.request(request)
            .responseData(queue: queue) { (responseData) in
     
            completion(responseData.data, responseData.response, responseData.error)
        }
    }
    
    // MARK: - Request with endPoint
    
    /// Request with endPoint - completion 回傳物件 (Data?, URLResponse?, Error?)
    @discardableResult
    public func request(endPoint: String,
                        method: AlamofireAdapter.HTTPMethod,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: [String: String]? = nil,
                        completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> DataRequest? {
        
        let urlString = baseUrlString + endPoint
        
        var afHeaders = HTTPHeaders()
        
        if let headers = headers {
            afHeaders = HTTPHeaders(headers)
        }

        let afMethod = AlamofireAdapter.getAlamofireHTTPMethod(method)
        Logger.log("🌐 [\(method.rawValue) Url]: \(urlString)")
        let request = session.request(urlString, method: afMethod, parameters: parameters, encoding: encoding, headers: afHeaders).responseData { (response) in

            let data = response.data
            let urlResponse = response.response
            let error = response.error
            
            completion(data, urlResponse, error)
        }
        return request
    }
}
