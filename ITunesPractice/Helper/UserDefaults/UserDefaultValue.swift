//
//  UserDefaultValue.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/26.
//

import Foundation

@propertyWrapper
struct UserDefaultValue<Value: Codable> {
    let key: String
    let defaultValue: Value
    let standard: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            UserDefaultsHelper.shared.get(forKey: key, as: Value.self) ?? defaultValue
        }
        set {
            UserDefaultsHelper.shared.set(newValue, forKey: key)
        }
    }
}
