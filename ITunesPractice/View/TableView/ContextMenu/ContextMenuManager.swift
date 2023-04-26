//
//  ContextMenuManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/26.
//

import UIKit

// MARK: - ContextMenuManager

class ContextMenuManager {
    static let shared = ContextMenuManager()

    func createAction(title: String, image: UIImage?, attributes: UIMenuElement.Attributes = [], handler: @escaping UIActionHandler) -> UIAction {
        return UIAction(title: title, image: image, attributes: attributes, state: .off, handler: handler)
    }
}

extension ContextMenuManager {
    private var rootVC: UIViewController? {
        UIApplication.shared.rootViewController
    }

    /// 創建音樂菜單
    func createTrackMenu(_ track: Track?, canEditPlayList: Bool) -> UIMenu? {
        guard let track else { return nil }
        let isInLibrary = UserDefaults.libraryTracks.contains(track)
        let addMenu = addMenu(track: track)
        let deleteMenu = deleteMenu(track: track)
        let shareAction = shareAction(track: track)
        let editPlayListMenu = editPlayListMenu(track: track)

        var children: [UIMenuElement] = []

        if isInLibrary {
            children.append(deleteMenu)
        } else {
            children.append(addMenu)
        }

        if canEditPlayList {
            children.append(editPlayListMenu)
        }

        children.append(shareAction)

        return UIMenu(title: "", children: children)
    }
}

extension ContextMenuManager {
    /// 從資料庫刪除
    private func deleteMenu(track: Track) -> UIMenu {
        let deleteAction = createAction(title: "從資料庫中刪除".localizedString(), image: AppImages.trash, attributes: .destructive) { [weak self] _ in
            let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除這首歌嗎？這也會從播放列表中移除".localizedString(), message: nil, preferredStyle: .actionSheet)
            // .default 和 .cancel 樣式的按鈕的顏色
            alertController.view.tintColor = UIColor.systemRed

            let deleteAction = UIAlertAction(title: "刪除歌曲".localizedString(), style: .destructive) { _ in
                UserDefaults.libraryTracks.removeAll { $0 == track }
                Utils.toast("已從資料庫中刪除".localizedString())
            }
            alertController.addAction(deleteAction)

            let cancelAction = UIAlertAction(title: "取消".localizedString(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            self?.rootVC?.present(alertController, animated: true, completion: nil)
        }
        let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])
        return deleteMenu
    }

    /// 加入資料庫
    private func addMenu(track: Track) -> UIMenu {
        let addAction = createAction(title: "加入資料庫".localizedString(), image: AppImages.plus) { _ in
            UserDefaults.libraryTracks.appendIfNotContains(track)
            Utils.toast("已加入資料庫".localizedString())
        }
        let addMenu = UIMenu(title: "", options: .displayInline, children: [addAction])
        return addMenu
    }

    /// 分享歌曲
    private func shareAction(track: Track) -> UIAction {
        let shareAction = createAction(title: "分享歌曲".localizedString(), image: AppImages.squareAndArrowUp) { [weak self] _ in
            guard let sharedUrl = URL(string: track.trackViewUrl) else {
                Logger.log("Shared url is nil")
                Utils.toast("分享失敗".localizedString())
                return
            }
            let activityVC = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)

            // 分享完成後的事件
            activityVC.completionWithItemsHandler = { _, completed, _, error in
                if completed {
                    Utils.toast("分享成功".localizedString())
                } else {
                    // 關閉分享彈窗也算分享失敗
                    Logger.log(error?.localizedDescription ?? "")
                    Utils.toast("分享失敗".localizedString())
                }
            }
            self?.rootVC?.present(activityVC, animated: true)
        }
        return shareAction
    }

    /// 修改待播清單
    private func editPlayListMenu(track: Track) -> UIMenu {
        let insertToFirstAction = createAction(title: "插播".localizedString(), image: AppImages.insertToFirst) { _ in
            UserDefaults.toBePlayedTracks.insert(track, at: 0)
            Utils.toast("已插播".localizedString())
        }
        let addToLastAction = createAction(title: "最後播放".localizedString(), image: AppImages.addToLast) { _ in
            UserDefaults.toBePlayedTracks.append(track)
            Utils.toast("將於最後播放".localizedString())
        }
        let addMenu = UIMenu(title: "", options: .displayInline, children: [insertToFirstAction, addToLastAction])
        return addMenu
    }
}
