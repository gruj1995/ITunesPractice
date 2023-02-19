//
//  Defs.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

// MARK: - Defs

enum RequestError: Error{
    case urlError
    case adapterError(error: Error)
}

enum ResponseError: Error {
    case nilData
    case nonHTTPResponse
    case tokenError
    case apiError(error: APIError)
}

public struct APIError: Error {
    public let data: Data?
    public let statusCode: Int
}

public enum ContentType: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded; charset=utf-8"
    case multiPartFormData = "multipart/form-data"
}
