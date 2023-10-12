//
//  HTTPMethod+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/11.
//

import Alamofire
import Foundation

extension HTTPMethod {
    /// 為了轉換已經寫好的 HTTPMethod 和 Alamofire 的 HTTPMethod，用這個 func 轉換
    func toAlamofireHTTPMethod() -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod(rawValue: self.rawValue)
    }
}
