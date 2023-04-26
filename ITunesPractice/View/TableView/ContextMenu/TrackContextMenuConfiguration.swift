//
//  TrackContextMenuConfiguration.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/3.
//

import UIKit

// MARK: - TrackContextMenuConfiguration

struct TrackContextMenuConfiguration {
    // MARK: Internal

    let indexPath: IndexPath
    let track: Track?

    func createContextMenuConfiguration() -> UIContextMenuConfiguration {
        let identifier = "\(indexPath.section).\(indexPath.row)" as NSCopying
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: previewViewControllerProvider, actionProvider: actionMenuProvider)
    }

    // MARK: Private

    // 這邊可以提供預覽圖要顯示的內容與尺寸，回傳 nil 則預設顯示被選中的元件
    private var previewViewControllerProvider: UIContextMenuContentPreviewProvider {
        let provider: UIContextMenuContentPreviewProvider = {
            let vc = TrackContextMenuViewController()
            vc.track = self.track
            let width = Constants.screenWidth * 0.9
            vc.preferredContentSize = CGSize(width: width, height: width * 0.3)
            return vc
        }
        return provider
    }

    // 上下文菜單
    private var actionMenuProvider: UIContextMenuActionProvider {
        let provider: UIContextMenuActionProvider = { _ -> UIMenu? in
            guard let track = self.track else { return nil }
            return ContextMenuManager.shared.createTrackMenu(track: track)
        }
        return provider
    }
}
