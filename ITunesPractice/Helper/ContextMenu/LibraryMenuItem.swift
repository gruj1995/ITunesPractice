//
//  LibraryMenuItem.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import UIKit

// MARK: - LibraryMenuItem

protocol LibraryMenuItem {
    func getMenuElement(for tracks: [Track]) -> UIMenuElement
}

// MARK: - AddMenuItem

/// 加入資料庫
struct AddToPlaylistMenuItem: LibraryMenuItem {
    func getMenuElement(for tracks: [Track]) -> UIMenuElement {
        let addAction = UIAction(title: "加入待播清單".localizedString(), image: AppImages.plus) { _ in
            tracks.forEach { print("__++ \($0.trackName)")}
//            // 新的插入到最前面
//            UserDefaults.libraryTracks.insertIfNotContains(track, at: 0)
//            Utils.toast("已加入資料庫".localizedString())
        }
        return UIMenu(title: "", options: .displayInline, children: [addAction])
    }
}

// MARK: - DeleteMenuItem

/// 從資料庫刪除
struct DeleteFromPlaylistMenuItem: LibraryMenuItem {
    func getMenuElement(for tracks: [Track]) -> UIMenuElement {
        let deleteAction = UIAction(title: "從資料庫中刪除".localizedString(), image: AppImages.trash, attributes: .destructive) { _ in
            let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除這些歌嗎？".localizedString(), message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "刪除歌曲".localizedString(), style: .destructive) { _ in
                UserDefaults.defaultPlaylist.tracks.removeAll { tracks.contains($0) }
                Utils.toast("已從資料庫中刪除".localizedString())
            }
            let cancelAction = UIAlertAction(title: "取消".localizedString(), style: .cancel, handler: nil)
            alertController.view.tintColor = .systemRed
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            let rootVC = UIApplication.shared.rootViewController
            rootVC?.present(alertController, animated: true, completion: nil)
        }
        return UIMenu(title: "", options: .displayInline, children: [deleteAction])
    }
}
