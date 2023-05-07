//
//  CloudOption.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/7.
//

import UIKit

enum CloudOption: CaseIterable {
    case iCloud
    case googleDrive

    var title: String {
        switch self {
        case .iCloud: return "iCloud"
        case .googleDrive: return "Google Drive"
        }
    }

    var image: UIImage? {
        switch self {
        case .iCloud: return AppImages.iCloud
        case .googleDrive: return AppImages.googleDrive
        }
    }
}
