//
//  UIView+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

extension UIView {
    var isVisible: Bool {
        if let window = window, superview != nil {
            return frame.intersects(window.bounds) && !isHidden
        }
        return false
    }

    func gesture(_ gestureType: GestureType) -> GesturePublisher {
        .init(view: self, gestureType: gestureType)
    }

    static func emptyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
