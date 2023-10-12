//
//  BodyDataEncoding.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation
import Alamofire

struct BodyDataEncoding: ParameterEncoding {
    private let body: Data
    init(body: Data) { self.body = body }
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body
        return urlRequest
    }
}

extension BodyDataEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyDataEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyURLRequest: return "Empty url request"
        case .encodingProblem: return "Encoding problem"
        }
    }
}
