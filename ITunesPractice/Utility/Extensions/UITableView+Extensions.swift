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
        return TrackContextMenuConfiguration(indexPath: indexPath, track: track).createContextMenuConfiguration()
    }

    /// 捲動到上方
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

    /// 左滑刪除按鈕
    func deleteConfiguration(_ completion: @escaping (() -> Void)) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "移除") { _, _, _ in
            completion()
        }
        deleteAction.backgroundColor = .appColor(.red1)

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        // 防止滑到底觸發第一個 button 的 action
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
