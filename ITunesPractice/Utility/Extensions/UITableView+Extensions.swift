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
            switch menuAction {
            case .addToLibrary(let track):
                var storedTracks = UserDefaults.standard.tracks
                storedTracks.appendIfNotContains(track)
                UserDefaults.standard.tracks = storedTracks
            case .deleteFromLibrary(let track):
                var storedTracks = UserDefaults.standard.tracks
                storedTracks.removeAll(where: { $0 == track })
                UserDefaults.standard.tracks = storedTracks
            case .share(let track):
                guard let sharedUrl = URL(string: track.trackViewUrl) else {
                    Logger.log("Shared url is nil")
                    return
                }
                let vc = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
                UIApplication.shared.keyWindowCompact?.rootViewController?.present(vc, animated: true)
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
        let visibleRect: CGRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)

        return (0 ..< numberOfSections).filter {
            let headerRect = (self.style == .plain) ? rect(forSection: $0): rectForHeader(inSection: $0)

            return visibleRect.intersects(headerRect)
        }
    }

    var visibleSectionHeaders: [UITableViewHeaderFooterView] {
        var visibleSects = [UITableViewHeaderFooterView]()
        for sectionIndex in indexesOfVisibleSections {
            if let sectionHeader = headerView(forSection: sectionIndex) {
                visibleSects.append(sectionHeader)
            }
        }

        return visibleSects
    }
}
