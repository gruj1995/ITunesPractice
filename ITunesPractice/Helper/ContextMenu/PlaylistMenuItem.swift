//
//  PlaylistMenuItem.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/9.
//

import UIKit

// MARK: - LibraryMenuItem

protocol PlaylistMenuItem {
    func getMenuElement(for playlist: Playlist, _ completion: @escaping (() -> Void)) -> UIMenuElement
}

// MARK: - EditMenuItem

/// 編輯
struct EditMenuItem: PlaylistMenuItem {
    func getMenuElement(for playlist: Playlist, _ completion: @escaping (() -> Void)) -> UIMenuElement {
        let editAction = UIAction(title: "編輯".localizedString(), image: AppImages.pencil) { _ in
            completion()
        }
        return UIMenu(title: "", options: .displayInline, children: [editAction])
    }
}

// MARK: - DeleteMenuItem

/// 從資料庫刪除
struct DeleteFromLibraryMenuItem: PlaylistMenuItem {
    func getMenuElement(for playlist: Playlist, _ completion: @escaping (() -> Void)) -> UIMenuElement {
        let deleteAction = UIAction(title: "從資料庫中刪除".localizedString(), image: AppImages.trash, attributes: .destructive) { _ in
            let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除此播放列表嗎？".localizedString(), message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "刪除播放列表".localizedString(), style: .destructive) { _ in
                UserDefaults.playlists.removeAll { $0 == playlist }
                Utils.toast("已從資料庫中刪除".localizedString())
                completion()
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
