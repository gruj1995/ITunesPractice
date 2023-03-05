//
//  HTTPMethod.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation
import Alamofire

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
/// `HTTPMethod.get != HTTPMethod(rawValue: "get")`.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3

extension AlamofireAdapter {
    public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
        /// `CONNECT` method.
        public static let connect = HTTPMethod(rawValue: "CONNECT")
        /// `DELETE` method.
        public static let delete = HTTPMethod(rawValue: "DELETE")
        /// `GET` method.
        public static let get = HTTPMethod(rawValue: "GET")
        /// `HEAD` method.
        public static let head = HTTPMethod(rawValue: "HEAD")
        /// `OPTIONS` method.
        public static let options = HTTPMethod(rawValue: "OPTIONS")
        /// `PATCH` method.
        public static let patch = HTTPMethod(rawValue: "PATCH")
        /// `POST` method.
        public static let post = HTTPMethod(rawValue: "POST")
        /// `PUT` method.
        public static let put = HTTPMethod(rawValue: "PUT")
        /// `TRACE` method.
        public static let trace = HTTPMethod(rawValue: "TRACE")

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// 為了轉換已經寫好的 HTTPMethod 和 Alamofire 的 HTTPMethod，用這個 func 轉換
    public static func getAlamofireHTTPMethod(_ method: HTTPMethod) -> Alamofire.HTTPMethod {
        
        switch method {
        case .connect:
            return .connect
        case .delete:
            return .delete
        case .get:
            return .get
        case .head:
            return .head
        case .options:
            return .options
        case .patch:
            return .patch
        case .post:
            return .post
        case .put:
            return .put
        case .trace:
            return .trace
        default:
            return .get
        }
    }
}
