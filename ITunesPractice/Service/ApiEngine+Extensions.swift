//
//  ApiEngine+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/11.
//

import Alamofire
import Foundation

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
