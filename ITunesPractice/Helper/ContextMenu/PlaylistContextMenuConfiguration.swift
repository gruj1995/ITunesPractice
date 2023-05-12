//
//  PlaylistContextMenuConfiguration.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/9.
//

import UIKit

// MARK: - PlaylistContextMenuConfiguration

struct PlaylistContextMenuConfiguration {
    // MARK: Internal

    let indexPath: IndexPath
    let playlist: Playlist?

    func createContextMenuConfiguration() -> UIContextMenuConfiguration {
        let identifier = "\(indexPath.section).\(indexPath.item)" as NSCopying
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil, actionProvider: actionMenuProvider)
    }

    // MARK: Private

//    // 這邊可以提供預覽圖要顯示的內容與尺寸，回傳 nil 則預設顯示被選中的元件
//    private var previewViewControllerProvider: UIContextMenuContentPreviewProvider {
//        return nil
////        let provider: UIContextMenuContentPreviewProvider = {
////            let vc = TrackContextMenuViewController()
////            vc.track = self.track
////            let width = Constants.screenWidth * 0.9
////            vc.preferredContentSize = CGSize(width: width, height: width * 0.3)
////            return vc
////        }
////        return provider
//    }

    // 上下文菜單
    private var actionMenuProvider: UIContextMenuActionProvider {
        let provider: UIContextMenuActionProvider = { _ -> UIMenu? in
            guard let playlist else { return nil }
            return ContextMenuManager.shared.createPlaylistMenu(playlist) {

            }
        }
        return provider
    }
}
