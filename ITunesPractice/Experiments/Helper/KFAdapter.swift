//
//  KFAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/17.
//

import UIKit
import Kingfisher

class KFAdapter {

    static let shared = KFAdapter()

    // 避免外部直接生成 KFAdapter()
    private init() {}

    /// 透過 url 下載圖片到指定的 UIImageView 中
    func loadImage(with url: URL, placeholder: Placeholder?, into imageView: UIImageView) {
        // 使用 activity 樣式的指示器來提示使用者等待時間
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, placeholder: placeholder)
    }

    /// 透過 urlString 下載圖片到指定的 UIImageView 中
    func loadImage(with urlString: String, placeholder: Placeholder?, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        loadImage(with: url, placeholder: placeholder, into: imageView)
    }

    /// 透過 ImageResource 下載圖片到指定的 UIImageView 中
    func loadImage(with resource: Source, placeholder: Placeholder?, into imageView: UIImageView) {
        // 使用 activity 樣式的指示器來提示使用者等待時間
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: resource, placeholder: placeholder)
    }

    /// 通過 ImagePrefetcher 類別將圖片預先下載到本地緩存中，提高圖片顯示效率
    func preloadImage(with url: URL) {
        let prefetcher = ImagePrefetcher(urls: [url])
        prefetcher.start()
    }

    func preloadImage(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        preloadImage(with: url)
    }
}
