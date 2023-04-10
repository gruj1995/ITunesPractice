//
//  UserDefaultsHelper.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/3.
//

import Foundation

// MARK: - UserDefaultsHelper

class UserDefaultsHelper {
    // MARK: Internal

    static let shared = UserDefaultsHelper()

    func set<T: Encodable>(_ value: T?, forKey key: String) {
        if let value = value {
            if let data = try? encoder.encode(value) {
                defaults.set(data, forKey: key)
            } else {
                defaults.set(nil, forKey: key)
            }
        } else {
            defaults.set(nil, forKey: key)
        }
        // TODO: 似乎可以刪除
        defaults.synchronize()
    }

    func get<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    // MARK: Private

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
}
