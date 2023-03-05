//
//  ApiEngine.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Alamofire
import Foundation

// MARK: - ApiEngine

public class ApiEngine {
    // MARK: Public

    public static let shared = ApiEngine()

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
            .responseData(queue: queue) { responseData in
                completion(responseData.data, responseData.response, responseData.error)
            }
    }
    
    /// Request with URLRequest - completion 回傳物件 (Result<T, CMApiEngineError>)
    @discardableResult
    public func requestDecodableWithResult<T: Decodable>(_ request: URLRequest,
                                                         queue: DispatchQueue = .main,
                                                         completion: @escaping (Result<T, ApiEngineError>) -> Void) -> DataRequest {

        let dataRequest = self.request(request, queue: queue) { (data, response, error) in
            let result: Result<T, ApiEngineError> = self.convertResult(data: data, response: response, error: error)
            completion(result)
        }
        return dataRequest
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

        let request = session.request(urlString, method: afMethod, parameters: parameters, encoding: encoding, headers: afHeaders).responseData { response in

            let data = response.data
            let urlResponse = response.response
            let error = response.error

            completion(data, urlResponse, error)
        }
        return request
    }
    
    /// Request with endPoint - completion 回傳物件 (Result<T, CMApiEngineError>)
    @discardableResult
    public func requestDecodableWithResult<T: Decodable>(
        endPoint: String,
        method: AlamofireAdapter.HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, ApiEngineError>) -> Void) -> DataRequest? {
 
        return request(
            endPoint: endPoint,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers) { (data, response, error) in
                let result: Result<T, ApiEngineError> = self.convertResult(data: data, response: response, error: error)
                completion(result)
        }
    }

    // MARK: Internal

    lazy var session = AlamofireAdapter.shared.getSession()

    var baseUrlString: String {
        return Constants.domain
    }
}

// MARK: - convertResult

extension ApiEngine {
    /// 轉換Result(物件和錯誤)
    func convertResult<T: Decodable>(data: Data?,
                                     response: URLResponse?,
                                     error: Error?) -> Result<T, ApiEngineError> {
        // 有錯誤
        if let error = error {
            return .failure(ApiEngineError(data: data, error: error, response: response))
        }

        // 有狀態碼錯誤 - 401,404,500...
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode >= 200, httpResponse.statusCode < 300
        else {
            return .failure(ApiEngineError(data: data, error: error, response: response))
        }

        // 無資料
        guard let data = data else {
            if let nilDataResponse = NilDataResponse(statusCode: httpResponse.statusCode) as? T {
                return .success(nilDataResponse)
            } else {
                return .failure(ApiEngineError(data: nil, error: error, response: response))
            }
        }

        // 轉換物件
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            let afError = AFError.responseSerializationFailed(reason: .decodingFailed(error: error))
            return .failure(ApiEngineError(data: data, error: afError, response: response))
        }
    }
}
