//
//  YoutubeAPIError.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation

struct YoutubeErrorResponse: Codable {
    let error: ErrorInfo?

    struct ErrorInfo: Codable {
        let code: Int?
        let message: String?
        let errors: [ErrorDetail]?
        let status: String?
        let details: [ErrorDetail]?

        struct ErrorDetail: Codable {
            let message: String?
            let reason: String?

            enum CodingKeys: String, CodingKey {
                case message
                case reason
            }
        }
    }
}
