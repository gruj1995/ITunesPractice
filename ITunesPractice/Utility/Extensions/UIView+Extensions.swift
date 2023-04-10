//
//  UIView+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

extension UIView {
    func gesture(_ gestureType: GestureType) -> GesturePublisher {
        .init(view: self, gestureType: gestureType)
    }

    static func emptyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
