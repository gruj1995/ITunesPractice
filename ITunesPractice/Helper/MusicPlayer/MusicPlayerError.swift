//
//  MusicPlayerError.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/24.
//

import Foundation

// MARK: - MusicPlayerError

enum MusicPlayerError: LocalizedError {
    case invalidTrack
    case invalidIndex
    case emptyPlaylist

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .invalidTrack:
            return "無效的曲目"
        case .invalidIndex:
            return "指向清單曲目的索引無效"
        case .emptyPlaylist:
            return "尚未添加曲目至播放清單中"
        }
    }
}
