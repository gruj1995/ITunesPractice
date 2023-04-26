//
//  UserDefaultValue.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/26.
//

import Foundation
import Combine

// 參考文章： https://www.avanderlee.com/swift/property-wrappers/

@propertyWrapper
struct UserDefaultValue<Value: Codable> {
    let key: String
    let defaultValue: Value
    // 外部可以替換預設的 UserDefaults 容器，比如透過 UserDefaults(suiteName: "group.com.squareMusic.app") 生成
    let container: UserDefaults = .standard
    private let publisher = PassthroughSubject<Value, Never>()

    var wrappedValue: Value {
        get {
            get(forKey: key, as: Value.self) ?? defaultValue
        }
        set {
            set(newValue, forKey: key)
            publisher.send(newValue)
        }
    }

    // 使用投影值觀察值的變化
    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }

    private func get<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = container.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func set<T: Encodable>(_ value: T?, forKey key: String) {
        if let value = value {
            if let data = try? JSONEncoder().encode(value) {
                container.set(data, forKey: key)
            } else {
                container.set(nil, forKey: key)
            }
        } else {
            container.set(nil, forKey: key)
        }
    }
}
