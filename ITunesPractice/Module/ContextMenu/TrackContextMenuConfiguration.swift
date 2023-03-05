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

    enum TrackContextMenuAction {
        case addToLibrary(Track)
        case deleteFromLibrary(Track)
        case share(Track)
    }

    typealias TrackContextMenuActionHandler = (TrackContextMenuAction) -> Void

    let index: Int
    let track: Track?
    let actionHandler: TrackContextMenuActionHandler

    func createContextMenuConfiguration() -> UIContextMenuConfiguration {
        let identifier = String(index) as NSCopying
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: previewViewControllerProvider, actionProvider: actionMenuProvider)
    }

    // MARK: Private

    // Provides the content preview that displays when the user selects the item.
    // 這邊可以提供預覽圖要顯示的內容與尺寸，回傳 nil 則預設顯示被選中的元件
    private var previewViewControllerProvider: UIContextMenuContentPreviewProvider? {
        let provider: UIContextMenuContentPreviewProvider? = {
            let vc = TrackContextMenuViewController()
            vc.track = self.track
            let width = Constants.screenWidth * 0.9
            vc.preferredContentSize = CGSize(width: width, height: width * 0.3)
            return vc
        }
        return provider
    }

    // Provides a UIMenu describing the contextual menu.
    private var actionMenuProvider: UIContextMenuActionProvider? {
        let provider: UIContextMenuActionProvider? = { _ -> UIMenu? in
            guard let track = self.track else { return nil }
            let isAdded = UserDefaults.standard.tracks.contains(track)

            let addAction = self.createAction(title: "加入資料庫".localizedString(), image: UIImage(systemName: "plus")) { _ in
                self.actionHandler(.addToLibrary(track))
            }
            let addMenu = UIMenu(title: "", options: .displayInline, children: [addAction])

            let deleteAction = self.createAction(title: "從資料庫中刪除".localizedString(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.actionHandler(.deleteFromLibrary(track))
            }
            let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])

            let shareAction = self.createAction(title: "分享歌曲".localizedString(), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.actionHandler(.share(track))
            }

            if isAdded {
                return UIMenu(title: "", children: [deleteMenu, shareAction])
            } else {
                return UIMenu(title: "", children: [addMenu, shareAction])
            }
        }
        return provider
    }

    private func createAction(title: String, image: UIImage?, attributes: UIMenuElement.Attributes = [], handler: @escaping UIActionHandler) -> UIAction {
        return UIAction(title: title, image: image, attributes: attributes, state: .off, handler: handler)
    }
}
