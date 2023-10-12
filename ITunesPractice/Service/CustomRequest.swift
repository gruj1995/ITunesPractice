//
//  CustomRequest.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

/// 基底Request
protocol CustomRequest {

    /// 基底Response
    associatedtype Response: Decodable

    /// HTTPMethod
    var method: HTTPMethod { get }

    /// 請求轉接器(發送前處理)
    var adapters: [CustomRequestAdapter] { get }
    
    /// 決策路徑(接收回應後處理)
//    var decisions: [CMDecision] { get }
}
    
extension CustomRequest {
    
    /// 建立Request
    func buildRequest() throws -> URLRequest {
        guard let url = URL(string: Constants.itunesDomain) else {
            throw RequestError.urlError
        }
        let request = URLRequest(url: url)
        return try adapters.reduce(request) { try $1.adapted($0) }
    }
}

