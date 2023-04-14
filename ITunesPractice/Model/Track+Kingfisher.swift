//
//  Track+Kingfisher.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/13.
//

import Kingfisher
import UIKit

extension Track {
    func getCoverImage(size: ITunesImageSize, _ completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url = getArtworkImageWithSize(size: size) else {
            completion(.failure(ImageError.invalidUrl))
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                Logger.log("Image: \(value.image). Got from: \(value.cacheType)")
                completion(.success(value.image))
            case .failure(let error):
                Logger.log(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}

// MARK: - ImageError

enum ImageError: LocalizedError {
    case invalidUrl

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .invalidUrl: return "無效的圖片連結"
        }
    }
}
