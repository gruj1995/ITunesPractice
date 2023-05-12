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

    /// 音樂選單
    func createTrackMenu(_ track: Track?, menuTypes: [TrackMenuType]) -> UIMenu? {
        guard let track else { return nil }
        let children = menuTypes.map { $0.getMenuElement(for: track) }
        return UIMenu(title: "", children: children)
    }

    /// 資料庫編輯選單
    func createLibraryMenu(_ tracks: [Track]) -> UIMenu {
        let children = [
            AddToPlaylistMenuItem().getMenuElement(for: tracks),
            DeleteFromPlaylistMenuItem().getMenuElement(for: tracks)
        ]
        return UIMenu(title: "", children: children)
    }

    /// 播放清單選單
    func createPlaylistMenu(_ playlist: Playlist, _ completion: @escaping (() -> Void)) -> UIMenu {
        var children: [UIMenuElement] = []
        // 全部歌曲的播放清單不可刪除
        if playlist.id == 1 {
            children = [EditMenuItem().getMenuElement(for: playlist, completion)]
        } else {
            children = [
                EditMenuItem().getMenuElement(for: playlist, completion),
                DeleteFromLibraryMenuItem().getMenuElement(for: playlist, completion)
            ]
        }
        return UIMenu(title: "", children: children)
    }

    /// 照片選單
    func createPhotoMenu(_ vc: Photographable) -> UIMenu {
        let children = [
            PhotoMenuItem().getMenuElement(vc)
        ]
        return UIMenu(title: "", children: children)
    }
}
