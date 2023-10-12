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
        elements.forEach { appendIfNotContains($0) }
    }

    @discardableResult
    mutating func insertIfNotContains(_ element: Element, at index: Index) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            insert(element, at: index)
            return (true, element)
        }
    }
}

extension Collection {
    func isValidIndex(_ index: Index) -> Bool {
        indices.contains(index)
    }
}

extension Collection where Index == Int {
    /// 取得陣列的隨機索引（不含指定 index）
    func randomIndexExcluding(_ index: Int) -> Index {
        let indices = self.indices.filter { $0 != index }
        return indices.randomElement() ?? 0
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
