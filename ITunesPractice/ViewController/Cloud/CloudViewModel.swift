//
//  CloudViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/7.
//

import Foundation
import AVFoundation

class CloudViewModel {
    let cloudOptions: [CloudOption] = CloudOption.allCases

    var totalCount: Int {
        cloudOptions.count
    }

    func cloudOption(forCellAt index: Int) -> CloudOption? {
        guard cloudOptions.indices.contains(index) else {
            return nil
        }
        return cloudOptions[index]
    }

    func convertToTracks(urls: [URL]) -> [Track] {
        // 判斷檔案是否為可播放的音檔
        let playableUrls = urls.compactMap { AVAsset(url: $0).isPlayable ? $0 : nil }
        if playableUrls.isEmpty {
            return []
        } else {
            return playableUrls.map { url in
                // 取得檔案名稱(去除副檔名)
                let fileName = url.deletingPathExtension().lastPathComponent
                return Track(trackName: fileName, previewUrl: url.absoluteString)
            }
        }
    }
}
