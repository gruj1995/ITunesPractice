//
//  UITableView+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import UIKit

extension UITableView {
    /// 為 cell 創建 context menu configuration
    func createTrackContextMenuConfiguration(indexPath: IndexPath, track: Track?) -> UIContextMenuConfiguration {
        let configuration = TrackContextMenuConfiguration(indexPath: indexPath, track: track) { menuAction in

            let rootVC = UIApplication.shared.keyWindowCompact?.rootViewController

            switch menuAction {
            // 加入資料庫
            case .addToLibrary(let track):
                TrackDataManager.shared.addToLibrary(track)
                Utils.toast("已加入資料庫".localizedString())

            // 從資料庫刪除
            case .deleteFromLibrary(let track):
                let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除此專輯嗎？這也會從播放列表中移除此專輯的歌曲".localizedString(), message: nil, preferredStyle: .actionSheet)
                // .default 和 .cancel 樣式的按鈕的顏色
                alertController.view.tintColor = UIColor.systemRed

                let deleteAction = UIAlertAction(title: "刪除專輯".localizedString(), style: .destructive) { _ in
                    TrackDataManager.shared.removeFromLibrary(track)
                    Utils.toast("已從資料庫中刪除".localizedString())
                }
                alertController.addAction(deleteAction)

                let cancelAction = UIAlertAction(title: "取消".localizedString(), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)

                rootVC?.present(alertController, animated: true, completion: nil)

            // 分享歌曲
            case .share(let track):
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
                return
            }
        }
        return configuration.createContextMenuConfiguration()
    }

    func scrollToTop(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: animated)
            }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }

    /// tableView 最後的 section 是否可見
    func isLastSectionReached() -> Bool {
        guard numberOfSections > 0 else {
            return true
        }

        let lastSectionIndex = numberOfSections - 1
        let numberOfRowsInLastSection = numberOfRows(inSection: lastSectionIndex)

        guard numberOfRowsInLastSection > 0 else {
            var sectionIndex = lastSectionIndex - 1

            while sectionIndex >= 0 {
                let numberOfRows = numberOfRows(inSection: sectionIndex)

                if numberOfRows > 0 {
                    return false
                }

                sectionIndex -= 1
            }

            return true
        }

        let lastRowIndex = numberOfRowsInLastSection - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        let lastVisibleIndexPaths = indexPathsForVisibleRows ?? []

        return lastVisibleIndexPaths.contains(lastIndexPath)
    }

    // github文件 https://stackoverflow.com/questions/15204328/how-to-retrieve-all-visible-table-section-header-views/23538021#23538021

    var indexesOfVisibleSections: [Int] {
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)

        return (0 ..< numberOfSections).filter {
            let headerRect = (self.style == .plain) ? rect(forSection: $0) : rectForHeader(inSection: $0)

            return visibleRect.intersects(headerRect)
        }
    }

    var visibleSectionHeaders: [UITableViewHeaderFooterView] {
        var visibleSects = [UITableViewHeaderFooterView]()
        for sectionIndex in self.indexesOfVisibleSections {
            if let sectionHeader = headerView(forSection: sectionIndex) {
                visibleSects.append(sectionHeader)
            }
        }

        return visibleSects
    }
}
