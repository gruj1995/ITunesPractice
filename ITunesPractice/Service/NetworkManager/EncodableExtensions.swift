//
//  EncodableExtensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        return(try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)).flatMap {$0 as? [String: Any]}
    }

    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else {return nil}
        return String(data: data, encoding: .utf8)
    }

    var encoded: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let stringData = formatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(stringData)
        }
        return try? encoder.encode(self)
    }
}
