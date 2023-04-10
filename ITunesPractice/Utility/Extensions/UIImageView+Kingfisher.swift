//
//  UIImageView+Kingfisher.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/1.
//

import Kingfisher
import UIKit

extension UIImageView {
    func loadCoverImage(with url: URL?) {
        loadImage(with: url, placeholder: DefaultTrack.coverImage)
    }

    func loadImage(with url: URL?, placeholder: UIImage? = nil) {
        kf.setImage(with: url, placeholder: placeholder)
    }
}
