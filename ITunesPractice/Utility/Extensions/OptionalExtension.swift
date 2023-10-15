//
//  OptionalExtension.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/15.
//

import Foundation

extension Optional where Wrapped: Collection {

    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }

    mutating func appendAndSetIfNil<E>(_ element: Wrapped.Element) where Wrapped == [E] {
        self = (self ?? []) + [element]
    }

    mutating func appendAndSetIfNil<S>(contentsOf newElements: S) where S: Sequence, Wrapped == [S.Element] {
        self = (self ?? []) + newElements
    }
}
