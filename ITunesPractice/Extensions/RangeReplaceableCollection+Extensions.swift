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
}
