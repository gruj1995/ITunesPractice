//
//  RangeReplaceableCollection+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/5.
//

import Foundation

// https://stackoverflow.com/questions/46519004/can-somebody-give-a-snippet-of-append-if-not-exists-method-in-swift-array
extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }

    mutating func appendIfNotContains(_ elements: [Element]) {
        for element in elements {
            appendIfNotContains(element)
        }
    }
}

extension Collection {
    func isValidIndex(_ index: Index) -> Bool {
        return indices.contains(index)
    }

    func isNotEmpty() -> Bool {
        return !isEmpty
    }
}

extension Collection where Index == Int {
    /// 取得陣列中排除指定 index 外的隨機索引
    func randomIndexExcluding(_ index: Int) -> Index {
        let indices = self.indices.filter { $0 != index }
        return indices.randomElement() ?? 0
    }
}
