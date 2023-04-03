//
//  RepeatMode.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/25.
//

import UIKit

// MARK: - RepeatMode

enum RepeatMode: CaseIterable {
    case none // 不重複
    case all // 全部循環
    case one // 單曲循環

    var image: UIImage? {
        switch self {
        case .one: return AppImages.repeat1
        default: return AppImages.repeat0
        }
    }
}
