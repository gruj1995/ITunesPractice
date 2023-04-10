//
//  GestureSubscription.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/14.
//

import Combine
import UIKit

// Subscription 協議繼承自 Cancellable 協議，後者為我們提供了cancel()用於處理訂閱取消的方法。

class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType, S.Failure == Never {
    // MARK: Lifecycle

    init(subscriber: S, view: UIView, gestureType: GestureType) {
        self.subscriber = subscriber
        self.view = view
        self.gestureType = gestureType
        configureGesture(gestureType)
    }

    // MARK: Internal
    // Subscription 必須實作 request、cancel 方法
    func request(_ demand: Subscribers.Demand) {}

    // 取消訂閱
    func cancel() {
        subscriber = nil
    }

    // MARK: Private

    private var subscriber: S?
    private var gestureType: GestureType
    private var view: UIView

    private func configureGesture(_ gestureType: GestureType) {
        let gesture = gestureType.get()
        gesture.addTarget(self, action: #selector(handler))
        view.addGestureRecognizer(gesture)
    }

    @objc
    private func handler() {
        _ = subscriber?.receive(gestureType)
    }
}
