//
//  NetworkManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()

    lazy var session = AlamofireAdapter.shared.getSession()

    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
//        if let token = UserDefaults.user?.guid {
//            let header = HTTPHeader.authorization(bearerToken: token)
//            headers.add(header)
//        }
        return headers
    }

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .custom({ decoder  in
//            let container = try decoder.singleValueContainer()
//            let dateString = try container.decode(String.self)
//
//            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            if let date = self.formatter.date(from: dateString) {
//                return date
//            }
//            self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//            if let date = self.formatter.date(from: dateString) {
//                return date
//            }
//            self.formatter.dateFormat = "yyyy/MM/dd"
//            if let date = self.formatter.date(from: dateString) {
//                return date
//            }
//            self.formatter.dateFormat = "yyyy/MM/dd a hh:mm:ss"
//            if let date = self.formatter.date(from: dateString) {
//                return date
//            }
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string:\(dateString)")
//
//        })
        return decoder
    }()

    enum Action {
        // Youtube
        case ytAutoSuggest // 搜尋自動建議關鍵字
        case ytSearchVideos // 搜尋清單
        case ytVideoInfo // 指定影片的資訊(包含其他推薦影片)

        var apiDomain: String {
            UserDefaults.apiDomain
        }

        var url: String {
            switch self {
            case .ytAutoSuggest:
                return "https://clients1.google.com/complete/search"
            case .ytSearchVideos:
                return "\(apiDomain)/search"
            case .ytVideoInfo:
                return "\(apiDomain)/videoInfo"
            }
        }
    }
}

