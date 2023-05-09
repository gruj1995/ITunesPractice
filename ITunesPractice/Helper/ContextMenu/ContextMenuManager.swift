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

    /// 創建資料庫編輯菜單
    func createLibraryMenu(_ tracks: [Track]) -> UIMenu {
        let children = [
            AddToPlaylistMenuItem().getMenuElement(for: tracks),
            DeleteFromPlaylistMenuItem().getMenuElement(for: tracks)
        ]
        return UIMenu(title: "", children: children)
    }

    func createPhotoMenu(_ vc: Photographable) -> UIMenu {
        let children = [
            PhotoMenuItem().getMenuElement(vc)
        ]
        return UIMenu(title: "", children: children)
    }
}
