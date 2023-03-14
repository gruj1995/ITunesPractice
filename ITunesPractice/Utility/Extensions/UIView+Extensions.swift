//
//  UIView+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

extension UIView {
    func gesture(_ gestureType: GestureType = .tap()) -> GesturePublisher {
        .init(view: self, gestureType: gestureType)
    }
}
