//
//  PreviewType.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/2.
//

import UIKit

enum PreviewType: Int {
    case artist
    case album
    case track

    var title: String {
        switch self {
        case .artist: return "歌手預覽".localizedString()
        case .album: return "專輯預覽".localizedString()
        case .track: return "單曲預覽".localizedString()
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .artist: return UIImage(systemName: "person.fill")
        case .album: return UIImage(systemName: "music.note.list")
        case .track: return UIImage(systemName: "play.fill")
        }
    }
}
