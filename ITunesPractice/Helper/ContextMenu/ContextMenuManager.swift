//
//  ContextMenuManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/26.
//

import UIKit

// MARK: - ContextMenuManager

class ContextMenuManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = ContextMenuManager()

    /// 創建音樂菜單
    func createTrackMenu(_ track: Track?, menuTypes: [TrackMenuType]) -> UIMenu? {
        guard let track else { return nil }
        let children = menuTypes.map { $0.getMenuElement(for: track) }
        return UIMenu(title: "", children: children)
    }
}

// MARK: - TrackMenuType

enum TrackMenuType: TrackMenuItem {
    case addOrRemoveFromLibrary // 加入資料庫/從資料庫刪除
    case editPlaylist // 修改待播清單
    case share // 分享歌曲

    // MARK: Internal

    func getMenuElement(for track: Track) -> UIMenuElement {
        switch self {
        case .addOrRemoveFromLibrary:
            if track.isInLibrary {
                return DeleteMenuItem().getMenuElement(for: track)
            } else {
                return AddMenuItem().getMenuElement(for: track)
            }
        case .editPlaylist:
            let trackWithNewID = track.autoIncrementID()
            return EditPlaylistMenuItem().getMenuElement(for: trackWithNewID)
        case .share:
            return ShareMenuItem().getMenuElement(for: track)
        }
    }
}
