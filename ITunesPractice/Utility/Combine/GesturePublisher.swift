//
//  GesturePublisher.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/14.
//

import Combine
import UIKit

// 參考文章： https://jllnmercier.medium.com/combine-handling-uikits-gestures-with-a-publisher-c9374de5a478

// MARK: - GesturePublisher

// 手勢偵測
struct GesturePublisher: Publisher {
    // MARK: Lifecycle

    init(view: UIView, gestureType: GestureType) {
        self.view = view
        self.gestureType = gestureType
    }

    // MARK: Internal

    typealias Output = GestureType
    typealias Failure = Never

    func receive<S>(subscriber: S) where S: Subscriber,
        GesturePublisher.Failure == S.Failure, GesturePublisher.Output
        == S.Input {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            view: view,
            gestureType: gestureType
        )
        subscriber.receive(subscription: subscription)
    }

    // MARK: Private

    private let view: UIView
    private let gestureType: GestureType
}
