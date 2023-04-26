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
    /// 創建音樂菜單
    func createTrackMenu(track: Track) -> UIMenu {
        let rootVC = UIApplication.shared.rootViewController
        let isAdded = UserDefaults.standard.tracks.contains(track)

        // 加入資料庫
        let addAction = createAction(title: "加入資料庫".localizedString(), image: AppImages.plus) { _ in
            TrackDataManager.shared.addToLibrary(track)
            Utils.toast("已加入資料庫".localizedString())
        }
        let addMenu = UIMenu(title: "", options: .displayInline, children: [addAction])

        // 從資料庫刪除
        let deleteAction = createAction(title: "從資料庫中刪除".localizedString(), image: AppImages.trash, attributes: .destructive) { _ in
            let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除這首歌嗎？這也會從播放列表中移除".localizedString(), message: nil, preferredStyle: .actionSheet)
            // .default 和 .cancel 樣式的按鈕的顏色
            alertController.view.tintColor = UIColor.systemRed

            let deleteAction = UIAlertAction(title: "刪除歌曲".localizedString(), style: .destructive) { _ in
                TrackDataManager.shared.removeFromLibrary(track)
                Utils.toast("已從資料庫中刪除".localizedString())
            }
            alertController.addAction(deleteAction)

            let cancelAction = UIAlertAction(title: "取消".localizedString(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            rootVC?.present(alertController, animated: true, completion: nil)
        }
        let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])

        // 分享歌曲
        let shareAction = createAction(title: "分享歌曲".localizedString(), image: AppImages.squareAndArrowUp) { _ in
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
            rootVC?.present(activityVC, animated: true)
        }

        if isAdded {
            return UIMenu(title: "", children: [deleteMenu, shareAction])
        } else {
            return UIMenu(title: "", children: [addMenu, shareAction])
        }
    }
}
